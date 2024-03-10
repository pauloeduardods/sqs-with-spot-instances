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

const (
	COMMON_TAG_KEY   = "SPOT_INSTANCE_COMMON_TAG"
	COMMON_TAG_VALUE = "spot-instance-created-by-lambda"
)

type EC2Service struct {
	client *ec2.Client
	config EC2Config
}

type EC2Config struct {
	MaxSpotInstancePrice float64
	InstanceType         string
	ImageId              string
	MaxInstances         int
	// KeyName              string
	// SecurityGroupIds     []string
	// SubnetId             string
	// InstanceProfileArn   string
	// RoleArn              string
	// SpotInstanceTag string
}

func NewEC2Service() (*EC2Service, error) {
	awsConfig, err := config.NewAWSConfig()
	if err != nil {
		logger.Error("Error creating AWS config: %v", err)
		return nil, fmt.Errorf("error creating AWS config: %v", err)
	}

	return &EC2Service{
		client: awsConfig.EC2Client,
		config: EC2Config{
			MaxSpotInstancePrice: 0.01,
			InstanceType:         "t2.micro",
			ImageId:              "ami-0f403e3180720dd7e",
			// KeyName:              "your-key-pair-name",
			// SecurityGroupIds:     []string{"your-security-group-id"},
			// SubnetId:             "your-subnet-id",
			// InstanceProfileArn:   "your-instance-profile-arn",
			// RoleArn:              "your-role-arn",
			// SpotInstanceTag: "spot-instance-created-by-lambda",
			MaxInstances: 1,
		},
	}, nil
}

type Instance struct {
	InstanceId            *string
	State                 string
	SpotInstanceRequestId string
}

type CheckForExistingSpotInstanceRequestOut struct {
	Active    int
	Open      int
	Instances []Instance
}

func (s *EC2Service) CheckForExistingSpotInstanceRequest() (CheckForExistingSpotInstanceRequestOut, error) {
	input := &ec2.DescribeSpotInstanceRequestsInput{
		Filters: []types.Filter{
			{
				Name:   aws.String("tag:" + COMMON_TAG_KEY),
				Values: []string{COMMON_TAG_VALUE},
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
		Active:    0,
		Open:      0,
		Instances: []Instance{},
	}

	for _, request := range result.SpotInstanceRequests {
		instance := Instance{
			SpotInstanceRequestId: *request.SpotInstanceRequestId,
			InstanceId:            request.InstanceId,
			State:                 string(request.State),
		}
		out.Instances = append(out.Instances, instance)
		if request.State == types.SpotInstanceStateOpen {
			out.Open++
		} else if request.State == types.SpotInstanceStateActive {
			out.Active++
		}
	}

	logger.Info("Spot instance requests: %v", out)

	return out, nil
}

type CreateSpotInstanceInput struct {
	Count int
	Price float64
}

func (s *EC2Service) CreateSpotInstance(params CreateSpotInstanceInput) error {
	if params.Count > s.config.MaxInstances {
		logger.Error("Error creating spot instance: count exceeds maximum instances")
		return fmt.Errorf("error creating spot instance: count exceeds maximum instances")
	}
	if params.Price > s.config.MaxSpotInstancePrice {
		logger.Error("Error creating spot instance: price exceeds maximum spot instance price")
		return fmt.Errorf("error creating spot instance: price exceeds maximum spot instance price")
	}

	input := &ec2.RequestSpotInstancesInput{
		Type:          types.SpotInstanceTypeOneTime,
		InstanceCount: aws.Int32(int32(params.Count)),
		SpotPrice:     aws.String(fmt.Sprintf("%f", params.Price)),
		LaunchSpecification: &types.RequestSpotLaunchSpecification{
			ImageId:      aws.String(s.config.ImageId),
			InstanceType: types.InstanceType(s.config.InstanceType),
			// KeyName:      aws.String(s.config.KeyName),
			// SecurityGroupIds:     s.config.SecurityGroupIds,
			// SubnetId:             aws.String(s.config.SubnetId),
			// IamInstanceProfile:   &types.IamInstanceProfileSpecification{Arn: aws.String(s.config.InstanceProfileArn)},
			// Monitoring:           &types.RunInstancesMonitoringEnabled{Enabled: true},
			// TagSpecifications: []types.TagSpecification{
			// 	{
			// 		ResourceType: types.ResourceTypeInstance,
			// 		Tags: []types.Tag{
			// 			{
			// 				Key:   aws.String("SPOT_INSTANCE_COMMON_TAG"),
			// 				Value: aws.String(s.config.SpotInstanceTag),
			// 			},
			// 		},
			// 	},
			// },
		},
		ValidUntil: aws.Time(time.Now().Add(1 * time.Hour)),
	}

	result, err := s.client.RequestSpotInstances(context.Background(), input)
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
					Key:   aws.String(COMMON_TAG_KEY),
					Value: aws.String(COMMON_TAG_VALUE),
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

// func (s *EC2Service) Delete
