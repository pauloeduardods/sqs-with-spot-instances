package sqs

import (
	"context"
	"fmt"
	"resize-asg/internal/config"
	"resize-asg/pkg/Logger"
	"strconv"

	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
)

var logger = Logger.NewLogger()

type SQS struct {
	client   *sqs.Client
	queueUrl string
}

func NewSQS(queueUrl string, config *config.AWSConfig) (*SQS, error) {

	return &SQS{
		client:   config.SQSClient,
		queueUrl: queueUrl,
	}, nil
}

func (s *SQS) GetTotalQueueMessages() (int, error) {
	result, err := s.client.GetQueueAttributes(context.TODO(), &sqs.GetQueueAttributesInput{
		QueueUrl: &s.queueUrl,
		AttributeNames: []types.QueueAttributeName{
			types.QueueAttributeNameApproximateNumberOfMessages,
			types.QueueAttributeNameApproximateNumberOfMessagesNotVisible,
			types.QueueAttributeNameApproximateNumberOfMessagesDelayed,
		},
	})
	if err != nil {
		logger.Error("Error getting queue attributes: %v", err)
		return 0, fmt.Errorf("Error getting queue attributes: %v", err)
	}

	totalMessages := 0

	for _, attributeName := range []string{
		"ApproximateNumberOfMessages",
		"ApproximateNumberOfMessagesNotVisible",
		"ApproximateNumberOfMessagesDelayed",
	} {
		numMessages, ok := result.Attributes[attributeName]
		if !ok {
			logger.Error("Attribute %s not found", attributeName)
			continue
		}

		numMessagesInt, err := strconv.Atoi(numMessages)
		if err != nil {
			logger.Error("Error converting number of messages to int for %s: %v", attributeName, err)
			continue
		}

		totalMessages += numMessagesInt
	}

	return totalMessages, nil
}
