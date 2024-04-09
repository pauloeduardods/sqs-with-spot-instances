package orchestrator

import (
	"fmt"
	"resize-ecs/internal/config"
	"resize-ecs/internal/ecs"
	"resize-ecs/internal/sqs"
	"resize-ecs/pkg/Logger"
)

var logger = Logger.NewLogger()

type Orchestrator struct {
	sqsClient        *sqs.SQS
	ecsClient        *ecs.ECS
	minContainers    int
	maxContainers    int
	messageThreshold int
}

func NewOrchestrator(conf *config.AWSConfig) (*Orchestrator, error) {
	envs := config.NewEnvironment()

	sqsClient, err := sqs.NewSQS(envs.SqsQueueUrl, conf)
	if err != nil {
		return nil, fmt.Errorf("Error creating SQS client: %w", err)
	}

	ecsClient, err := ecs.NewECS(envs.EcsClusterName, envs.EcsServiceName, conf)
	if err != nil {
		return nil, fmt.Errorf("Error creating ECS client: %w", err)
	}

	return &Orchestrator{
		sqsClient:        sqsClient,
		ecsClient:        ecsClient,
		minContainers:    envs.MinContainers,
		maxContainers:    envs.MaxContainers,
		messageThreshold: envs.MessageThreshold,
	}, nil
}

func (o *Orchestrator) calculateDesiredContainers(messages int) int {
	if messages <= 0 {
		return o.minContainers
	}
	desired := (messages / o.messageThreshold) + o.minContainers
	if desired < o.minContainers {
		return o.minContainers
	}
	if desired > o.maxContainers {
		return o.maxContainers
	}
	return desired
}

func (o *Orchestrator) Orchestrate() error {
	logger.Info("Orchestrating")
	totalMessages, err := o.sqsClient.GetTotalQueueMessages()
	logger.Info("Total messages in queue: %d", totalMessages)
	if err != nil {
		logger.Error("Error getting total queue messages: %v", err)
		return fmt.Errorf("error getting total queue messages: %w", err)
	}

	desiredContainers := o.calculateDesiredContainers(totalMessages)
	currentCapacity, err := o.ecsClient.GetDesiredCount()

	if desiredContainers == 0 && totalMessages > 0 && currentCapacity != 0 { // Don't scale down to 0 if there are messages in the queue and at least one container is running
		desiredContainers = 1
	}

	logger.Info("Desired containers: %d, Current capacity: %d", desiredContainers, currentCapacity)
	if err != nil {
		logger.Error("Error getting current desired capacity: %v", err)
		return fmt.Errorf("error getting current desired capacity: %w", err)
	}
	if desiredContainers != int(currentCapacity) {
		err = o.ecsClient.SetDesiredCount(int32(desiredContainers))
		if err != nil {
			logger.Error("Error setting desired capacity: %v", err)
			return fmt.Errorf("error setting desired capacity: %w", err)
		}
		logger.Info("Desired capacity for ECS %s set to %d", o.ecsClient.ServiceName, desiredContainers)
	} else {
		logger.Info("Desired capacity for ECS %s already set to %d", o.ecsClient.ServiceName, desiredContainers)
	}

	return nil
}
