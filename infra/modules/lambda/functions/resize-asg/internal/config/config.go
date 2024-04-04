package config

import (
	"context"
	"fmt"
	"os"
	"resize-asg/pkg/Logger"
	"strconv"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/autoscaling"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

var logger = Logger.NewLogger()

type Environment struct {
	Region           string
	SqsQueueUrl      string
	ASGName          string
	MinContainers    int
	MaxContainers    int
	MessageThreshold int
}

func NewEnvironment() *Environment {
	region := os.Getenv("REGION")
	if region == "" {
		logger.Error("REGION environment variable not set")
		panic("REGION environment variable not set")
	}

	sqsQueueUrl := os.Getenv("SQS_QUEUE_URL")
	if sqsQueueUrl == "" {
		logger.Error("SQS_QUEUE_URL environment variable not set")
		panic("SQS_QUEUE_URL environment variable not set")
	}

	asgName := os.Getenv("ASG_NAME")
	if asgName == "" {
		logger.Error("ASG_NAME environment variable not set")
		panic("ASG_NAME environment variable not set")
	}

	minContainers, err := strconv.Atoi(os.Getenv("MIN_CONTAINERS"))
	if err != nil {
		logger.Error("Error converting MIN_CONTAINERS to int: %v", err)
		panic(fmt.Errorf("Error converting MIN_CONTAINERS to int: %w", err))
	}

	maxContainers, err := strconv.Atoi(os.Getenv("MAX_CONTAINERS"))
	if err != nil {
		logger.Error("Error converting MAX_CONTAINERS to int: %v", err)
		panic(fmt.Errorf("Error converting MAX_CONTAINERS to int: %w", err))
	}

	messageThreshold, err := strconv.Atoi(os.Getenv("MESSAGE_THRESHOLD"))
	if err != nil {
		logger.Error("Error converting MESSAGE_THRESHOLD to int: %v", err)
		panic(fmt.Errorf("Error converting MESSAGE_THRESHOLD to int: %w", err))
	}

	return &Environment{
		Region:           region,
		SqsQueueUrl:      sqsQueueUrl,
		ASGName:          asgName,
		MinContainers:    minContainers,
		MaxContainers:    maxContainers,
		MessageThreshold: messageThreshold,
	}
}

type AWSConfig struct {
	SQSClient *sqs.Client
	ASGClient *autoscaling.Client
}

func NewAWSConfig(ctx context.Context) (*AWSConfig, error) {
	env := NewEnvironment()

	cfg, err := config.LoadDefaultConfig(ctx,
		config.WithRegion(env.Region),
	)

	if err != nil {
		logger.Error("Error loading AWS configuration: %v", err)
		return nil, fmt.Errorf("Error loading AWS configuration: %v", err)
	}

	return &AWSConfig{
		SQSClient: sqs.NewFromConfig(cfg),
		ASGClient: autoscaling.NewFromConfig(cfg),
	}, nil
}
