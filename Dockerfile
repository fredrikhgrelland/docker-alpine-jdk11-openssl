FROM azul/zulu-openjdk-alpine:11-jre-headless

ARG TEST_DOWNLOAD_BUILD_ARGUMENT=https://nrk.no

#Add ca_certificates to the image ( if trust is not already added through base image )
COPY ca_certificates /usr/local/share/ca-certificates

RUN apk --no-cache add curl=~7 ca-certificates=20191127-r4 openssl=1.1.1g-r0 \
    && find /usr/local/share/ca-certificates -not -name "*.crt" -type f -delete \
    && update-ca-certificates 2>/dev/null || true && echo "NOTE: CA warnings suppressed." \
    # Test download
    && curl -s -L -o /dev/null ${TEST_DOWNLOAD_BUILD_ARGUMENT} || printf "\n###############\nERROR: You are probably behind a corporate proxy. Add your custom ca .crt in the conf/certificates docker build folder\n###############\n"