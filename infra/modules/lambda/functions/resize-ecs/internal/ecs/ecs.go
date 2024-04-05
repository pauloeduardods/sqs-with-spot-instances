package ecs

import (
	"context"
	"errors"
	"fmt"
	"resize-ecs/internal/config"
	"resize-ecs/pkg/Logger"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/ecs"
	"github.com/aws/smithy-go"
)

var logger = Logger.NewLogger()

type ECS struct {
	client      *ecs.Client
	ClusterName string
	ServiceName string
}

func NewECS(clusterName, serviceName string, config *config.AWSConfig) (*ECS, error) {
	return &ECS{
		client:      config.ECSClient,
		ClusterName: clusterName,
		ServiceName: serviceName,
	}, nil
}

func (m *ECS) SetDesiredCount(desiredCount int32) error {
	input := &ecs.UpdateServiceInput{
		Cluster:      aws.String(m.ClusterName),
		Service:      aws.String(m.ServiceName),
		DesiredCount: aws.Int32(desiredCount),
	}

	_, err := m.client.UpdateService(context.TODO(), input)
	if err != nil {
		var ae smithy.APIError
		if errors.As(err, &ae) && ae.ErrorCode() == "ServiceUpdateInProgress" {
			logger.Error("Service update in progress for ECS %s; request to change desired count to %d will not be retried.", m.ServiceName, desiredCount)
			return fmt.Errorf("service update in progress for ECS %s; request to change desired count to %d will not be retried", m.ServiceName, desiredCount)
		} else {
			logger.Error("Error setting desired count: %v", err)
			return fmt.Errorf("error setting desired count for ECS %s: %w", m.ServiceName, err)
		}
	}

	logger.Info("Successfully set desired count for ECS %s to %d", m.ServiceName, desiredCount)
	return nil
}

func (m *ECS) GetDesiredCount() (int32, error) {
	input := &ecs.DescribeServicesInput{
		Cluster:  aws.String(m.ClusterName),
		Services: []string{m.ServiceName},
	}

	result, err := m.client.DescribeServices(context.TODO(), input)
	if err != nil {
		logger.Error("Error describing ECS service: %v", err)
		return 0, fmt.Errorf("error describing ECS service %s: %w", m.ServiceName, err)
	}

	if len(result.Services) == 0 {
		logger.Error("ECS service %s not found", m.ServiceName)
		return 0, fmt.Errorf("ECS service %s not found", m.ServiceName)
	}

	service := result.Services[0]
	return service.DesiredCount, nil
}
