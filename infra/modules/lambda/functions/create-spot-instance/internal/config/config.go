package config

import (
	"context"
	"create-spot-instance/utils/Logger"
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

var logger = Logger.NewLogger()

type Environment struct {
	Region string
}

func NewEnvironment() *Environment {
	region := os.Getenv("AWS_REGION")
	if region == "" {
		logger.Error("AWS_REGION environment variable not set")
		return nil
	}

	return &Environment{
		Region: region,
	}
}

type AWSConfig struct {
	EC2Client *ec2.Client
	SQSClient *sqs.Client
	Region    string
}

func NewAWSConfig() (*AWSConfig, error) {
	env := NewEnvironment()

	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(env.Region),
	)

	if err != nil {
		logger.Error("Error loading AWS configuration: %v", err)
		return nil, fmt.Errorf("Error loading AWS configuration: %v", err)
	}

	return &AWSConfig{
		EC2Client: ec2.NewFromConfig(cfg),
		SQSClient: sqs.NewFromConfig(cfg),
		Region:    cfg.Region,
	}, nil
}
