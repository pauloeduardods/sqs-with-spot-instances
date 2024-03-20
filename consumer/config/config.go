package config

import (
	"context"
	"fmt"
	"os"
	"strconv"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
)

type Environment struct {
	Region      string
	SqsQueueUrl string
	MaxWorkers  int
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

	maxWorkers := os.Getenv("MAX_WORKERS")
	maxWorkersInt, err := strconv.Atoi(maxWorkers)
	if err != nil || maxWorkers == "" {
		return nil, fmt.Errorf("MAX_WORKERS environment variable not set")
	}
	if maxWorkersInt < 1 {
		return nil, fmt.Errorf("MAX_WORKERS must be greater than 0")
	}

	return &Environment{
		Region:      region,
		SqsQueueUrl: sqsQueueUrl,
		MaxWorkers:  maxWorkersInt,
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
