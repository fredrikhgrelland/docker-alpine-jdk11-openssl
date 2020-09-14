![Docker](https://github.com/fredrikhgrelland/docker-hadoop/workflows/Docker/badge.svg)
# docker-alpine-jdk11-openssl
Docker image for creating java keystores from pem files.
Based on azul/zulu-openjdk-alpine:11-jre-headless.

You can use this image to run openssl and keytool in sequence in order to produce a pkcs12 compliant keystore for mTLS

This image can be built and operated behind a corporate proxy where the base os needs to trust a custom CA. [See this](./ca_certificates/README.md)
While building locally using the Makefile, you may set the environment variable CUSTOM_CA to a file or directory in order to import them.

## Published images
- [dockerhub](https://hub.docker.com/r/fredrikhgrelland/alpine-jdk11-openssl)
- [github](https://github.com/fredrikhgrelland/docker-alpine-jdk11-openssl/packages)

## Build locally for development
`make build`

If behind a corporate proxy with custom CA:
`CUSTOM_CA=/usr/local/share/ca-certificates make`

## Nomad example job
```
job "test" {
  datacenters = ["dc1"]
  group "test" {
    count = 1
    task "certificate-handler" {
      driver = "docker"
      config {
        image = "fredrikhgrelland/alpine-jdk11-openssl"
        entrypoint = [
          "/bin/sh"]
        args = [
          "-c",
          "openssl pkcs12 -export -password pass:changeit -in /local/leaf.pem -inkey /local/leaf.key -certfile /local/leaf.pem -out /local/presto.p12; keytool -noprompt -importkeystore -srckeystore /local/presto.p12 -srcstoretype pkcs12 -destkeystore /local/presto.jks -deststoretype JKS -deststorepass changeit -srcstorepass changeit; keytool -noprompt -import -trustcacerts -keystore /local/presto.jks -storepass changeit -alias Root -file /local/roots.pem; keytool -noprompt -importkeystore -srckeystore /local/presto.jks -destkeystore /alloc/presto.jks -deststoretype pkcs12 -deststorepass changeit -srcstorepass changeit; tail -f /dev/null"
        ]
      }
      template {
        data = "{{with caLeaf \"coordinator\" }}{{ .CertPEM }}{{ end }}"
        destination = "local/leaf.pem"
      }
      template {
        data = "{{with caLeaf \"coordinator\" }}{{ .PrivateKeyPEM }}{{ end }}"
        destination = "local/leaf.key"
      }
      template {
        data = "{{ range caRoots }}{{ .RootCertPEM }}{{ end }}"
        destination = "local/roots.pem"
      }
    }
  }
}
```