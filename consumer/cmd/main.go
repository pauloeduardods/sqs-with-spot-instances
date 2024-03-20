package main

import (
	"consumer/cmd/sqs"
	"consumer/config"
	"consumer/pkg/Logger"
	"context"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	log := Logger.NewLogger()

	log.Info("Starting application")

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	env, err := config.NewEnvironment()
	if err != nil {
		log.Error("Error loading environment: %v", err)
		os.Exit(1)
	}

	awsCfg, err := config.NewAWSConfig(ctx, env)
	if err != nil {
		log.Error("Error loading AWS configuration: %v", err)
		os.Exit(1)
	}

	s := sqs.NewSQS(log, awsCfg, env.SqsQueueUrl, nil, env.MaxWorkers)

	go s.StartConsumer(ctx)

	<-ctx.Done()
	log.Warning("Interrupt signal received, initiating graceful shutdown")
	log.Info("Application exited gracefully")
}
