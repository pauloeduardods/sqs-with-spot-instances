package main

import (
	"context"
	"encoding/json"
	"resize-asg/internal/config"
	"resize-asg/internal/orchestrator"
	"resize-asg/pkg/Logger"

	"github.com/aws/aws-lambda-go/lambda"
)

var logger = Logger.NewLogger()

func HandleRequest(ctx context.Context, event json.RawMessage) (string, error) {
	logger.Info("Received event: %s", event)
	conf, err := config.NewAWSConfig(ctx)
	if err != nil {
		logger.Error("Error creating AWS config: %v", err)
		return "", err
	}

	orch, err := orchestrator.NewOrchestrator(conf)

	if err != nil {
		logger.Error("Error creating orchestrator: %v", err)
		return "", err
	}

	err = orch.Orchestrate()
	if err != nil {
		logger.Error("Error orchestrating: %v", err)
		return "", err
	}

	return "Success", nil
}

func main() {
	lambda.Start(HandleRequest)
}
