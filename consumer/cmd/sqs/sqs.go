package sqs

import (
	"consumer/pkg/Logger"
	"context"
	"sync"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	sqsTypes "github.com/aws/aws-sdk-go-v2/service/sqs/types"
)

type ICallback func(ctx context.Context, message sqsTypes.Message) error

type SQS struct {
	client     *sqs.Client
	logger     *Logger.Logger
	queueUrl   string
	callback   ICallback
	maxWorkers int
}

func NewSQS(logger *Logger.Logger, cfg *aws.Config, queueUrl string, callback ICallback, maxWorkers int) *SQS {
	return &SQS{
		client:     sqs.NewFromConfig(*cfg),
		logger:     logger,
		queueUrl:   queueUrl,
		callback:   callback,
		maxWorkers: maxWorkers,
	}
}

func (s *SQS) StartConsumer(ctx context.Context) {
	s.logger.Info("Starting consumer with maxWorkers: %d", s.maxWorkers)
	var wg sync.WaitGroup
	workers := make(chan struct{}, s.maxWorkers)

	for {
		if err := s.consumeBatch(ctx, &wg, workers); err != nil {
			s.logger.Error("Error in consumeBatch: %v", err)
			time.Sleep(10 * time.Second)
		}
	}
}

func (s *SQS) consumeBatch(ctx context.Context, wg *sync.WaitGroup, workers chan struct{}) error {
	select {
	case <-ctx.Done():
		s.logger.Warning("SQS message consumption stopped by context")
		wg.Wait()
		return ctx.Err()
	default:
		return s.fetchAndProcessMessages(ctx, wg, workers)
	}
}

func (s *SQS) fetchAndProcessMessages(ctx context.Context, wg *sync.WaitGroup, workers chan struct{}) error {
	messages, err := s.fetchMessages(ctx)
	if err != nil {
		return err
	}

	for _, message := range messages {
		s.processMessage(ctx, wg, workers, message)
	}

	return nil
}

func (s *SQS) fetchMessages(ctx context.Context) ([]sqsTypes.Message, error) {
	resp, err := s.client.ReceiveMessage(ctx, &sqs.ReceiveMessageInput{
		QueueUrl:            &s.queueUrl,
		MaxNumberOfMessages: int32(s.maxWorkers),
		WaitTimeSeconds:     20,
	})
	if err != nil {
		s.logger.Error("Error receiving messages: %v", err)
		return nil, err
	}
	return resp.Messages, nil
}

func (s *SQS) processMessage(ctx context.Context, wg *sync.WaitGroup, workers chan struct{}, message sqsTypes.Message) {
	wg.Add(1)
	workers <- struct{}{}

	go func(msg sqsTypes.Message) {
		defer wg.Done()
		defer func() { <-workers }()

		if err := s.callback(ctx, msg); err != nil {
			s.logger.Error("Error processing message: %v", err)
			return
		}

		if err := s.deleteMessage(ctx, msg.ReceiptHandle); err != nil {
			s.logger.Error("Failed to delete message: %v", err)
		}
	}(message)
}

func (s *SQS) deleteMessage(ctx context.Context, receiptHandle *string) error {
	_, err := s.client.DeleteMessage(ctx, &sqs.DeleteMessageInput{
		QueueUrl:      &s.queueUrl,
		ReceiptHandle: receiptHandle,
	})
	if err != nil {
		s.logger.Error("Error deleting message: %v", err)
	}
	return err
}
