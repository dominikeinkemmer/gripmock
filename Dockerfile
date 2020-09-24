FROM golang:alpine

RUN mkdir /proto

RUN mkdir /stubs

RUN apk -U --no-cache add git protobuf

RUN go get -u -v github.com/golang/protobuf/protoc-gen-go \
	google.golang.org/grpc \
	google.golang.org/grpc/reflection \
	golang.org/x/net/context \
	github.com/go-chi/chi \
	github.com/lithammer/fuzzysearch/fuzzy \
	golang.org/x/tools/imports \
	github.com/golang/mock/gomock

RUN go get -u -v github.com/gobuffalo/packr/v2/... \
	github.com/gobuffalo/packr/v2/packr2

# cloning well-known-types
RUN git clone https://github.com/google/protobuf.git /protobuf-repo

RUN mkdir protobuf

# only use needed files
RUN mv /protobuf-repo/src/ /protobuf/

RUN rm -rf /protobuf-repo

RUN mkdir -p /go/src/github.com/dominikeinkemmer/gripmock

COPY . /go/src/github.com/dominikeinkemmer/gripmock

WORKDIR /go/src/github.com/dominikeinkemmer/gripmock/protoc-gen-gripmock

RUN packr2

# install generator plugin
RUN go install -v

RUN packr2 clean

WORKDIR /go/src/github.com/dominikeinkemmer/gripmock

# install gripmock
RUN go install -v

EXPOSE 4770 4771

ENTRYPOINT ["gripmock"]
