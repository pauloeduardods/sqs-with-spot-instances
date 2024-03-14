FROM golang:1.20-bullseye as build

RUN apt-get update && \
    apt-get install -y libtesseract-dev libleptonica-dev tesseract-ocr-eng && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . ./

RUN make build

FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y ca-certificates libtesseract4 libleptonica-dev tesseract-ocr tesseract-ocr-eng && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
# COPY --from=build /workspace/main_stripped /app/main
COPY --from=build /workspace/bin/main /app/main


RUN chmod +x /app/main
ENTRYPOINT [ "./main" ]


