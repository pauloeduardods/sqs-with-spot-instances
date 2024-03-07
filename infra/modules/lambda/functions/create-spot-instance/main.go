package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
)

const (
	LOG_ERROR   = "Error"
	LOG_INFO    = "Info"
	LOG_WARNING = "Warning"

	LOG_HANDLE_REQUEST = "HandleRequest"
)

func HandleRequest(ctx context.Context, event json.RawMessage) (string, error) {
	log.Printf("%s %s: Event received: %s\n", LOG_HANDLE_REQUEST, LOG_INFO, event)

	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-east-1"),
	)
	if err != nil {
		log.Printf("%s %s: Error loading AWS configuration: %v\n", LOG_HANDLE_REQUEST, LOG_ERROR, err)
		return "", fmt.Errorf("%s %s: Error loading AWS configuration: %v", LOG_HANDLE_REQUEST, LOG_ERROR, err)
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
		log.Printf("%s %s: Error getting queue attributes: %v\n", LOG_HANDLE_REQUEST, LOG_ERROR, err)
		return "", fmt.Errorf("%s %s: Error getting queue attributes: %v", LOG_HANDLE_REQUEST, LOG_ERROR, err)
	}

	numMessages, ok := result.Attributes["ApproximateNumberOfMessages"]
	if !ok {
		log.Printf("%s %s: Error getting queue attributes: ApproximateNumberOfMessages not found\n", LOG_HANDLE_REQUEST, LOG_ERROR)
		return "", fmt.Errorf("%s %s: Error getting queue attributes: ApproximateNumberOfMessages not found", LOG_HANDLE_REQUEST, LOG_ERROR)
	}

	log.Printf("%s %s: Event processed successfully. Approximate number of messages in the queue: %s\n", LOG_HANDLE_REQUEST, LOG_INFO, numMessages)

	return fmt.Sprintf("Approximate number of messages in the queue: %s", numMessages), nil
}

func main() {
	lambda.Start(HandleRequest)
}
