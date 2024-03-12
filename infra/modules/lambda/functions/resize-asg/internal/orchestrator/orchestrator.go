package orchestrator

import (
	"fmt"
	"resize-asg/internal/asg"
	"resize-asg/internal/config"
	"resize-asg/internal/sqs"
	"resize-asg/pkg/Logger"
)

var logger = Logger.NewLogger()

type Orchestrator struct {
	sqsClient        *sqs.SQS
	asgClient        *asg.ASG
	minInstances     int
	maxInstances     int
	messageThreshold int
}

func NewOrchestrator(conf *config.AWSConfig) (*Orchestrator, error) {
	envs := config.NewEnvironment()

	sqsClient, err := sqs.NewSQS(envs.SqsQueueUrl, conf)
	if err != nil {
		return nil, fmt.Errorf("Error creating SQS client: %w", err)
	}

	asgClient, err := asg.NewASG(envs.ASGName, conf)
	if err != nil {
		return nil, fmt.Errorf("Error creating ASG client: %w", err)
	}

	return &Orchestrator{
		sqsClient:        sqsClient,
		asgClient:        asgClient,
		minInstances:     envs.MinInstances,
		maxInstances:     envs.MaxInstances,
		messageThreshold: envs.MessageThreshold,
	}, nil
}

func (o *Orchestrator) calculateDesiredInstances(messages int) int {
	if messages <= 0 {
		return o.minInstances
	}
	desired := max(1, messages/o.messageThreshold) // 1 instance at least if messages > 0
	if desired < o.minInstances {
		return o.minInstances
	}
	if desired > o.maxInstances {
		return o.maxInstances
	}
	return desired
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func (o *Orchestrator) Orchestrate() error {
	totalMessages, err := o.sqsClient.GetTotalQueueMessages()
	if err != nil {
		logger.Error("Error getting total queue messages: %v", err)
		return fmt.Errorf("error getting total queue messages: %w", err)
	}

	desiredInstances := o.calculateDesiredInstances(totalMessages)

	currentCapacity, err := o.asgClient.GetDesiredCapacity()
	if err != nil {
		logger.Error("Error getting current desired capacity: %v", err)
		return fmt.Errorf("error getting current desired capacity: %w", err)
	}
	if desiredInstances != int(currentCapacity) {
		err = o.asgClient.SetDesiredCapacity(int32(desiredInstances))
		if err != nil {
			logger.Error("Error setting desired capacity: %v", err)
			return fmt.Errorf("error setting desired capacity: %w", err)
		}
		logger.Info("Desired capacity for ASG %s set to %d", o.asgClient.ASGName, desiredInstances)
	} else {
		logger.Info("Desired capacity for ASG %s already set to %d", o.asgClient.ASGName, desiredInstances)
	}

	return nil
}
