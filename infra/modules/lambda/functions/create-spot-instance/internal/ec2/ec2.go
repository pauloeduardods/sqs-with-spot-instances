package ec2

import (
	"context"
	"create-spot-instance/internal/config"
	"create-spot-instance/utils/Logger"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
)

var logger = Logger.NewLogger()

type EC2Service struct {
	client *ec2.Client
}

func NewEC2Service() (*EC2Service, error) {
	awsConfig, err := config.NewAWSConfig()
	if err != nil {
		logger.Error("Error creating AWS config: %v", err)
		return nil, fmt.Errorf("error creating AWS config: %v", err)
	}

	return &EC2Service{
		client: awsConfig.EC2Client,
	}, nil
}

type Instance struct {
	InstanceId            *string
	State                 string
	SpotInstanceRequestId string
}

type CheckForExistingSpotInstanceRequestOut struct {
	active    int
	open      int
	instances []Instance
}

func (s *EC2Service) CheckForExistingSpotInstanceRequest() (CheckForExistingSpotInstanceRequestOut, error) {
	input := &ec2.DescribeSpotInstanceRequestsInput{
		Filters: []types.Filter{
			{
				Name:   aws.String("tag:SPOT_INSTANCE_COMMON_TAG"),
				Values: []string{"spot-instance-created-by-lambda"},
			},
			{
				Name: aws.String("state"),
				Values: []string{
					string(types.SpotInstanceStateOpen),
					string(types.SpotInstanceStateActive),
				},
			},
		},
	}

	result, err := s.client.DescribeSpotInstanceRequests(context.Background(), input)
	if err != nil {
		logger.Error("Error describing spot instance requests: %v", err)
		return CheckForExistingSpotInstanceRequestOut{}, fmt.Errorf("error describing spot instance requests: %v", err)
	}

	out := CheckForExistingSpotInstanceRequestOut{
		active: 0,
		open:   0,
	}

	for _, request := range result.SpotInstanceRequests {
		instance := Instance{
			SpotInstanceRequestId: *request.SpotInstanceRequestId,
			InstanceId:            request.InstanceId,
			State:                 string(request.State),
		}
		out.instances = append(out.instances, instance)
		if request.State == types.SpotInstanceStateOpen {
			out.open++
		} else if request.State == types.SpotInstanceStateActive {
			out.active++
		}
	}

	logger.Info("Spot instance requests: %v", out)

	return out, nil
}

func (s *EC2Service) CheckForExistingSpotInstance() ([]Instance, error) { //Not working, instance dont have tag
	input := &ec2.DescribeInstancesInput{
		Filters: []types.Filter{
			{
				Name:   aws.String("instance-lifecycle"),
				Values: []string{"spot"},
			},
			{
				Name:   aws.String("instance-state-name"),
				Values: []string{"running"},
			},
			{
				Name:   aws.String("tag:SPOT_INSTANCE_COMMON_TAG"),
				Values: []string{"spot-instance-created-by-lambda"},
			},
		},
	}

	result, err := s.client.DescribeInstances(context.Background(), input)
	if err != nil {
		logger.Error("Error describing EC2 instances: %v", err)
		return nil, fmt.Errorf("error describing EC2 instances: %v", err)
	}

	// logger.Info("Result: %v", result)

	instanceList := []Instance{}
	logger.Info("Reservations: %v", result.Reservations)
	for _, reservation := range result.Reservations {
		if len(reservation.Instances) > 0 {
			for _, instance := range reservation.Instances {
				instanceList = append(instanceList, Instance{
					SpotInstanceRequestId: *instance.SpotInstanceRequestId,
					InstanceId:            instance.InstanceId,
					State:                 string(instance.State.Name),
				})
			}
		}
	}

	return instanceList, nil
}

func (s *EC2Service) CreateSpotInstance() error {
	input := &ec2.RequestSpotInstancesInput{
		InstanceCount: aws.Int32(1),
		Type:          types.SpotInstanceTypeOneTime,
		SpotPrice:     aws.String("0.01"),
		LaunchSpecification: &types.RequestSpotLaunchSpecification{
			ImageId:      aws.String("ami-0f403e3180720dd7e"), // Substitua pelo AMI desejado
			InstanceType: types.InstanceTypeT2Micro,           // Substitua pelo tipo de instância desejado
			// KeyName:      aws.String("your-key-pair-name"),    // Substitua pelo seu par de chaves
		},
		ValidUntil: aws.Time(time.Now().Add(1 * time.Hour)),
	}

	result, err := s.client.RequestSpotInstances(context.Background(), input) //Mudar isso aqui
	if err != nil {
		logger.Error("Error creating spot instance: %v", err)
		return fmt.Errorf("error creating spot instance: %v", err)
	}

	for _, instance := range result.SpotInstanceRequests {
		logger.Info("Spot instance request ID: %s", *instance.SpotInstanceRequestId)
		tagInput := &ec2.CreateTagsInput{
			Resources: []string{*instance.SpotInstanceRequestId},
			Tags: []types.Tag{
				{
					Key:   aws.String("SPOT_INSTANCE_COMMON_TAG"),
					Value: aws.String("spot-instance-created-by-lambda"),
				},
			},
		}
		_, err := s.client.CreateTags(context.Background(), tagInput)
		if err != nil {
			logger.Warning("Error tagging spot instance %s: %v", *instance.InstanceId, err)
			// remove spot instance request if tagging fails
		}
	}

	logger.Info("Spot instance created successfully")
	return nil
}
