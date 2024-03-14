package main

import "consumer/pkg/Logger"

var logger = Logger.NewLogger()

func main() {
	logger.Info("Starting consumer")
}
