package sqs

import (
	"consumer/pkg/Logger"
	"context"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

type SQS struct {
	client *sqs.Client
	logger *Logger.Logger
}

type ISQS interface {
	StartConsumer(ctx context.Context)
}

func NewSQS(logger *Logger.Logger, cfg *aws.Config) *SQS {
	return &SQS{
		client: sqs.NewFromConfig(*cfg),
		logger: logger,
	}
}

func (s *SQS) StartConsumer(ctx context.Context) {
	s.logger.Info("Starting consumer")

	for {
		select {
		case <-ctx.Done():
			s.logger.Info("Received signal to stop consumer")
			return
		}
	}
}
