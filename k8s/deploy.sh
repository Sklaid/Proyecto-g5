#!/bin/bash

# Kubernetes Deployment Helper Script
# Usage: ./deploy.sh [dev|prod|base] [apply|delete|status]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl not found. Please install kubectl."
        exit 1
    fi
    print_success "kubectl found"
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    print_success "Connected to Kubernetes cluster"
    
    echo ""
}

# Deploy function
deploy() {
    local env=$1
    local path=""
    
    case $env in
        dev)
            path="overlays/dev"
            ;;
        prod)
            path="overlays/prod"
            ;;
        base)
            path="base"
            ;;
        *)
            print_error "Invalid environment: $env"
            echo "Usage: $0 [dev|prod|base] [apply|delete|status]"
            exit 1
            ;;
    esac
    
    print_header "Deploying to $env"
    
    echo "Applying manifests from k8s/$path..."
    kubectl apply -k "k8s/$path"
    
    print_success "Deployment completed"
    echo ""
    
    # Wait for pods to be ready
    print_header "Waiting for Pods to be Ready"
    
    local namespace="observability"
    if [ "$env" = "dev" ]; then
        namespace="observability-dev"
    elif [ "$env" = "prod" ]; then
        namespace="observability-prod"
    fi
    
    echo "Waiting for pods in namespace: $namespace"
    kubectl wait --for=condition=ready pod --all -n $namespace --timeout=300s || true
    
    echo ""
    show_status $env
}

# Delete function
delete_deployment() {
    local env=$1
    local path=""
    
    case $env in
        dev)
            path="overlays/dev"
            ;;
        prod)
            path="overlays/prod"
            ;;
        base)
            path="base"
            ;;
        *)
            print_error "Invalid environment: $env"
            exit 1
            ;;
    esac
    
    print_header "Deleting deployment from $env"
    
    read -p "Are you sure you want to delete the $env deployment? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_warning "Deletion cancelled"
        exit 0
    fi
    
    echo "Deleting manifests from k8s/$path..."
    kubectl delete -k "k8s/$path"
    
    print_success "Deletion completed"
}

# Status function
show_status() {
    local env=$1
    local namespace="observability"
    
    if [ "$env" = "dev" ]; then
        namespace="observability-dev"
    elif [ "$env" = "prod" ]; then
        namespace="observability-prod"
    fi
    
    print_header "Deployment Status - $env"
    
    echo "Namespace: $namespace"
    echo ""
    
    echo "Pods:"
    kubectl get pods -n $namespace
    echo ""
    
    echo "Services:"
    kubectl get svc -n $namespace
    echo ""
    
    echo "PVCs:"
    kubectl get pvc -n $namespace
    echo ""
    
    echo "HPA:"
    kubectl get hpa -n $namespace 2>/dev/null || echo "No HPA found"
    echo ""
    
    # Get Grafana LoadBalancer IP
    print_header "Access Information"
    
    local grafana_ip=$(kubectl get svc -n $namespace -o jsonpath='{.items[?(@.metadata.name=="grafana")].status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    
    if [ -n "$grafana_ip" ]; then
        echo "Grafana: http://$grafana_ip:3000"
    else
        echo "Grafana: Use port-forward - kubectl port-forward svc/grafana 3000:3000 -n $namespace"
    fi
    
    echo "Prometheus: kubectl port-forward svc/prometheus 9090:9090 -n $namespace"
    echo "Tempo: kubectl port-forward svc/tempo 3200:3200 -n $namespace"
    echo "Demo App: kubectl port-forward svc/demo-app 3000:3000 -n $namespace"
}

# Main
main() {
    local env=${1:-base}
    local action=${2:-apply}
    
    check_prerequisites
    
    case $action in
        apply)
            deploy $env
            ;;
        delete)
            delete_deployment $env
            ;;
        status)
            show_status $env
            ;;
        *)
            print_error "Invalid action: $action"
            echo "Usage: $0 [dev|prod|base] [apply|delete|status]"
            exit 1
            ;;
    esac
}

# Run main
main "$@"
