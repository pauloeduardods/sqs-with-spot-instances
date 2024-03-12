package main

import (
	"context"
	"encoding/json"
	"resize-asg/pkg/Logger"
)

var logger = Logger.NewLogger()

func HandleRequest(ctx context.Context, event json.RawMessage) (string, error) {
	logger.Info("Event received: %s", event)
	return "Hello from Lambda!", nil
}

func main() {
	HandleRequest(context.Background(), nil)
	// lambda.Start(HandleRequest)
}
