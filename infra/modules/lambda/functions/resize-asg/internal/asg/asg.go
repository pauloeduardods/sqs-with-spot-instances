package asg

import (
	"context"
	"fmt"
	"resize-asg/internal/config"
	"resize-asg/pkg/Logger"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/autoscaling"
)

var logger = Logger.NewLogger()

type ASG struct {
	client  *autoscaling.Client
	ASGName string
}

func NewASG(asgName string, config *config.AWSConfig) (*ASG, error) {
	return &ASG{
		client:  config.ASGClient,
		ASGName: asgName,
	}, nil
}

func (m *ASG) SetDesiredCapacity(desiredCapacity int32) error {
	var honorCooldown bool = true
	if desiredCapacity <= 0 {
		honorCooldown = false
	}
	input := &autoscaling.SetDesiredCapacityInput{
		AutoScalingGroupName: &m.ASGName,
		DesiredCapacity:      &desiredCapacity,
		HonorCooldown:        aws.Bool(honorCooldown), // attention! Only set to false if desiredCapacity <= 0
	}

	_, err := m.client.SetDesiredCapacity(context.TODO(), input)
	if err != nil {
		logger.Error("Error setting desired capacity: %v", err)
		return fmt.Errorf("error setting desired capacity for ASG %s: %w", m.ASGName, err)
	}

	logger.Info("Successfully set desired capacity for ASG %s to %d", m.ASGName, desiredCapacity)
	return nil
}

func (m *ASG) GetDesiredCapacity() (int32, error) {
	input := &autoscaling.DescribeAutoScalingGroupsInput{
		AutoScalingGroupNames: []string{m.ASGName},
	}

	result, err := m.client.DescribeAutoScalingGroups(context.TODO(), input)
	if err != nil {
		logger.Error("Error describing ASG: %v", err)
		return 0, fmt.Errorf("error describing ASG %s: %w", m.ASGName, err)
	}

	if len(result.AutoScalingGroups) == 0 {
		logger.Error("ASG %s not found", m.ASGName)
		return 0, fmt.Errorf("ASG %s not found", m.ASGName)
	}

	asg := result.AutoScalingGroups[0]
	return *asg.DesiredCapacity, nil
}
