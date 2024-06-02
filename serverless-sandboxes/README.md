# Serving a simple HTTP reply function

Based on [Knative](https://knative.dev)'s original
[example](https://github.com/dewitt/knative-docs/blob/master/serving/samples/helloworld-go/README.md)
we built a simple httpreply function in go to showcase the functionality of
`knative-serving` with sandbox container runtimes.

## Requirements

- k8s / k3s
- knative installation
- kata installation
- ingress controller, able to route based on hostname

For ingress, we use `traefik` and do a catch-all subdomain match, which we forward to knative's `kourier` ingress controller. Not ideal ;-)

## Try it out! 

curl https://helloqemu.openinfra.nbfc.io
curl https://hellors.openinfra.nbfc.io
curl https://hellocontainer.openinfra.nbfc.io
curl https://hellofc.openinfra.nbfc.io

Or point your browser to one of the above URLs!
