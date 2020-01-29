FROM dva-registry.internal.salesforce.com/dva/spark-operator-builder:1 as builder

ENV workdir $GOPATH/src/github.com/GoogleCloudPlatform/spark-on-k8s-operator
RUN mkdir -p $workdir
WORKDIR $workdir
COPY . ./
COPY Gopkg.toml Gopkg.lock ./

RUN go generate && CGO_ENABLED=0 GOOS=linux go build -o /usr/bin/spark-operator

FROM dva-registry.internal.salesforce.com/dva/spark-2.4.0-sfdc:9
# This env var from the parent is mysteriously missing in the final image. WTF DOCKER?
ENV SPARK_HOME /opt/spark
COPY --from=builder /usr/bin/spark-operator /usr/bin/
COPY hack/gencerts.sh /usr/bin/
ENTRYPOINT ["/usr/bin/spark-operator"]