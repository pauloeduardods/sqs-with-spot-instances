package main

import (
	"context"
	"create-spot-instance/utils/Logger"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
)

var logger = Logger.NewLogger()

func HandleRequest(ctx context.Context, event json.RawMessage) (string, error) {
	logger.Info("Event received: %s", event)

	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-east-1"),
	)
	if err != nil {
		logger.Error("Error loading AWS configuration: %v", err)
		return "", fmt.Errorf("Error loading AWS configuration: %v", err)
	}

	client := sqs.NewFromConfig(cfg)

	queueUrl := "https://sqs.us-east-1.amazonaws.com/722354704330/dev-process-queue.fifo"

	result, err := client.GetQueueAttributes(context.TODO(), &sqs.GetQueueAttributesInput{
		QueueUrl: &queueUrl,
		AttributeNames: []types.QueueAttributeName{
			"ApproximateNumberOfMessages",
		},
	})
	if err != nil {
		logger.Error("Error getting queue attributes: %v", err)
		return "", fmt.Errorf("Error getting queue attributes: %v", err)
	}

	numMessages, ok := result.Attributes["ApproximateNumberOfMessages"]
	if !ok {
		logger.Error("Error getting queue attributes: ApproximateNumberOfMessages not found")
		return "", fmt.Errorf("Error getting queue attributes: ApproximateNumberOfMessages not found")
	}

	logger.Info("Approximate number of messages in the queue: %s", numMessages)

	return fmt.Sprintf("Approximate number of messages in the queue: %s", numMessages), nil
}

func main() {
	HandleRequest(context.Background(), nil)
	// lambda.Start(HandleRequest)
}
