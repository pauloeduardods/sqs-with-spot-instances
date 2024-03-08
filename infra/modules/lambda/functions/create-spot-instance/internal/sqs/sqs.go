package sqs

import (
	"context"
	"create-spot-instance/internal/config"
	"create-spot-instance/utils/Logger"
	"fmt"
	"strconv"

	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
)

var logger = Logger.NewLogger()

type SQS struct {
	client   *sqs.Client
	queueUrl string
}

type ISQS interface {
}

func NewSQS(queueUrl string) (*SQS, error) {
	awsConfig, err := config.NewAWSConfig()
	if err != nil {
		return nil, fmt.Errorf("Error creating AWS config: %v", err)
	}

	return &SQS{
		client:   awsConfig.SQSClient,
		queueUrl: queueUrl,
	}, nil
}

func (s *SQS) GetQueueApproximateNumberOfMessages() (int, error) {
	result, err := s.client.GetQueueAttributes(context.TODO(), &sqs.GetQueueAttributesInput{
		QueueUrl: &s.queueUrl,
		AttributeNames: []types.QueueAttributeName{
			"ApproximateNumberOfMessages",
		},
	})
	if err != nil {
		logger.Error("Error getting queue attributes: %v", err)
		return 0, fmt.Errorf("Error getting queue attributes: %v", err)
	}

	numMessages, ok := result.Attributes["ApproximateNumberOfMessages"]
	if !ok {
		logger.Error("Error getting queue attributes: ApproximateNumberOfMessages not found")
		return 0, fmt.Errorf("Error getting queue attributes: ApproximateNumberOfMessages not found")
	}

	numMessagesInt, err := strconv.Atoi(numMessages)
	if err != nil {
		logger.Error("Error converting number of messages to int: %v", err)
		return 0, fmt.Errorf("Error converting number of messages to int: %v", err)
	}

	return numMessagesInt, nil
}
