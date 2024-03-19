package config

import (
	"context"
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
)

type Environment struct {
	Region      string
	SqsQueueUrl string
}

func NewEnvironment() (*Environment, error) {
	region := os.Getenv("REGION")
	if region == "" {
		return nil, fmt.Errorf("REGION environment variable not set")
	}

	sqsQueueUrl := os.Getenv("SQS_QUEUE_URL")
	if sqsQueueUrl == "" {
		return nil, fmt.Errorf("SQS_QUEUE_URL environment variable not set")
	}

	return &Environment{
		Region:      region,
		SqsQueueUrl: sqsQueueUrl,
	}, nil
}

func NewAWSConfig(ctx context.Context, env *Environment) (*aws.Config, error) {
	cfg, err := config.LoadDefaultConfig(ctx,
		config.WithRegion(env.Region),
	)
	if err != nil {
		return nil, fmt.Errorf("error loading aws configuration: %v", err)
	}

	return &cfg, nil
}
