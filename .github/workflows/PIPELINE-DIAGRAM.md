# CI/CD Pipeline - Diagrama Visual

## Flujo Completo del Pipeline

```mermaid
graph TB
    Start([Push to main]) --> CI[CI Workflow]
    Start --> Docker[Docker Build Workflow]
    
    subgraph "CI - Build and Test"
        CI --> NodeTest[Node.js Tests]
        CI --> PythonTest[Python Tests]
        NodeTest --> NodeLint[Linters]
        PythonTest --> PythonLint[Flake8/Black/Pylint]
        NodeLint --> Coverage1[Coverage Report]
        PythonLint --> Coverage2[Coverage Report]
        Coverage1 --> CIStatus{All Pass?}
        Coverage2 --> CIStatus
    end
    
    subgraph "Docker Build and Push"
        Docker --> BuildApp[Build demo-app]
        Docker --> BuildDetector[Build anomaly-detector]
        BuildApp --> TagApp[Tag Images]
        BuildDetector --> TagDetector[Tag Images]
        TagApp --> PushApp[Push to GHCR]
        TagDetector --> PushDetector[Push to GHCR]
    end
    
    CIStatus -->|Pass| Deploy[Deploy Workflow]
    CIStatus -->|Fail| FailNotify[❌ Notify Failure]
    PushApp --> Deploy
    PushDetector --> Deploy
    
    subgraph "Deploy to Staging"
        Deploy --> PullImages[Pull Images from GHCR]
        PullImages --> DeployCompose[Deploy with docker-compose]
        DeployCompose --> Wait[Wait 30s]
        Wait --> SmokeTests[Smoke Tests]
        
        subgraph "Smoke Tests"
            SmokeTests --> HealthChecks[Health Checks]
            HealthChecks --> MetricsCheck[Metrics Validation]
            MetricsCheck --> TracesCheck[Traces Validation]
        end
        
        TracesCheck --> TestResult{Tests Pass?}
        TestResult -->|Pass| TagStable[Tag as Stable]
        TestResult -->|Fail| Rollback[🔄 Rollback]
        Rollback --> PullStable[Pull Stable Images]
        PullStable --> RedeployStable[Redeploy Stable]
    end
    
    TagStable --> ManualApproval{Manual Approval}
    
    subgraph "Deploy to Production"
        ManualApproval -->|Approved| ProdDeploy[Deploy to Production]
        ManualApproval -->|Rejected| End1([End])
        ProdDeploy --> ProdSmoke[Production Smoke Tests]
        ProdSmoke --> ProdResult{Tests Pass?}
        ProdResult -->|Pass| Success([✅ Success])
        ProdResult -->|Fail| ProdRollback[🔄 Rollback Production]
        ProdRollback --> End2([End])
    end
    
    style Start fill:#e1f5ff
    style CI fill:#fff4e1
    style Docker fill:#ffe1e1
    style Deploy fill:#f0e1ff
    style Success fill:#e1ffe1
    style FailNotify fill:#ffe1e1
    style Rollback fill:#ffe1e1
    style ProdRollback fill:#ffe1e1
```

---

## Workflows Detallados

### 1. CI Workflow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant CI as CI Workflow
    participant Node as Node.js Job
    participant Python as Python Job
    
    Dev->>GH: Push to main/develop
    GH->>CI: Trigger CI Workflow
    
    par Node.js Tests
        CI->>Node: Start Node.js Job
        Node->>Node: npm ci
        Node->>Node: npm run lint
        Node->>Node: npm test
        Node->>Node: Generate coverage
        Node->>GH: Upload coverage
    and Python Tests
        CI->>Python: Start Python Job
        Python->>Python: pip install
        Python->>Python: flake8/black/pylint
        Python->>Python: pytest
        Python->>Python: Generate coverage
        Python->>GH: Upload coverage
    end
    
    Node->>CI: Report status
    Python->>CI: Report status
    CI->>GH: Final status
    GH->>Dev: Notify result
```

### 2. Docker Build Workflow

```mermaid
sequenceDiagram
    participant GH as GitHub
    participant Docker as Docker Workflow
    participant Buildx as Docker Buildx
    participant GHCR as GitHub Container Registry
    
    GH->>Docker: Trigger on push
    Docker->>Buildx: Setup Buildx
    
    par Build demo-app
        Docker->>Buildx: Build demo-app
        Buildx->>Buildx: Use layer cache
        Buildx->>Docker: Image ready
    and Build anomaly-detector
        Docker->>Buildx: Build anomaly-detector
        Buildx->>Buildx: Use layer cache
        Buildx->>Docker: Image ready
    end
    
    Docker->>Docker: Tag images (SHA, latest)
    Docker->>GHCR: Push demo-app
    Docker->>GHCR: Push anomaly-detector
    GHCR->>Docker: Confirm push
    Docker->>GH: Report success
```

### 3. Deployment Workflow

```mermaid
sequenceDiagram
    participant GH as GitHub
    participant Deploy as Deploy Workflow
    participant GHCR as Container Registry
    participant Compose as Docker Compose
    participant Services as Services
    participant Tests as Smoke Tests
    
    GH->>Deploy: Trigger on main push
    Deploy->>GHCR: Pull latest images
    GHCR->>Deploy: Images downloaded
    
    Deploy->>Compose: docker-compose up -d
    Compose->>Services: Start all services
    Services->>Compose: Services running
    
    Deploy->>Deploy: Wait 30 seconds
    
    Deploy->>Tests: Run smoke tests
    Tests->>Services: Check /health endpoints
    Services->>Tests: 200 OK
    Tests->>Services: Check metrics
    Services->>Tests: Metrics available
    Tests->>Services: Check traces
    Services->>Tests: Traces available
    
    alt Tests Pass
        Tests->>Deploy: ✅ All tests passed
        Deploy->>GHCR: Tag images as stable
        Deploy->>GH: Request manual approval
        GH->>Deploy: Approval received
        Deploy->>Compose: Deploy to production
    else Tests Fail
        Tests->>Deploy: ❌ Tests failed
        Deploy->>GHCR: Pull stable images
        Deploy->>Compose: Rollback to stable
        Deploy->>GH: Notify failure
    end
```

---

## Estados del Pipeline

```mermaid
stateDiagram-v2
    [*] --> Pending: Push to main
    
    Pending --> Running: Workflow started
    
    Running --> Testing: CI Tests
    Running --> Building: Docker Build
    
    Testing --> TestsPassed: All tests pass
    Testing --> TestsFailed: Tests fail
    
    Building --> ImagesPushed: Images pushed
    Building --> BuildFailed: Build fails
    
    TestsPassed --> Deploying: Start deployment
    ImagesPushed --> Deploying: Start deployment
    
    Deploying --> SmokeTests: Services deployed
    
    SmokeTests --> Stable: Tests pass
    SmokeTests --> Rollback: Tests fail
    
    Rollback --> [*]: Rolled back
    
    Stable --> AwaitingApproval: Tagged as stable
    
    AwaitingApproval --> Production: Approved
    AwaitingApproval --> [*]: Rejected
    
    Production --> Success: Deployed
    Production --> ProdRollback: Failed
    
    ProdRollback --> [*]: Rolled back
    Success --> [*]: Complete
    
    TestsFailed --> [*]: Failed
    BuildFailed --> [*]: Failed
```

---

## Matriz de Decisiones

```mermaid
graph LR
    A[Push Event] --> B{Branch?}
    B -->|main| C[Full Pipeline]
    B -->|develop| D[CI + Docker Build]
    B -->|feature/*| E[CI Only]
    
    C --> F{CI Pass?}
    F -->|Yes| G{Docker Build Pass?}
    F -->|No| H[❌ Stop]
    
    G -->|Yes| I[Deploy Staging]
    G -->|No| H
    
    I --> J{Smoke Tests Pass?}
    J -->|Yes| K[Tag Stable]
    J -->|No| L[Rollback]
    
    K --> M{Manual Approval?}
    M -->|Yes| N[Deploy Production]
    M -->|No| O[End]
    
    N --> P{Prod Tests Pass?}
    P -->|Yes| Q[✅ Success]
    P -->|No| R[Rollback Prod]
    
    style C fill:#e1f5ff
    style D fill:#fff4e1
    style E fill:#ffe1e1
    style Q fill:#e1ffe1
    style H fill:#ffe1e1
    style L fill:#ffe1e1
    style R fill:#ffe1e1
```

---

## Timeline del Pipeline

```mermaid
gantt
    title CI/CD Pipeline Timeline
    dateFormat  mm:ss
    
    section CI
    Node.js Tests           :a1, 00:00, 02:00
    Python Tests            :a2, 00:00, 02:30
    
    section Docker
    Build demo-app          :b1, 02:00, 03:00
    Build anomaly-detector  :b2, 02:00, 03:00
    Push to GHCR           :b3, 05:00, 01:00
    
    section Deploy
    Pull Images            :c1, 06:00, 01:00
    Deploy Services        :c2, 07:00, 00:30
    Wait for Ready         :c3, 07:30, 00:30
    
    section Tests
    Health Checks          :d1, 08:00, 00:30
    Metrics Validation     :d2, 08:30, 00:30
    Traces Validation      :d3, 09:00, 00:30
    
    section Finalize
    Tag as Stable          :e1, 09:30, 00:30
    Manual Approval        :crit, e2, 10:00, 05:00
    Deploy Production      :e3, 15:00, 02:00
```

**Tiempo total estimado:**
- CI + Docker Build: ~6 minutos
- Deployment + Smoke Tests: ~4 minutos
- **Total (sin aprobación manual): ~10 minutos**

---

## Componentes del Sistema

```mermaid
graph TB
    subgraph "GitHub Actions"
        W1[CI Workflow]
        W2[Docker Workflow]
        W3[Deploy Workflow]
    end
    
    subgraph "Container Registry"
        GHCR[GitHub Container Registry]
        IMG1[demo-app:latest]
        IMG2[anomaly-detector:latest]
        IMG3[demo-app:stable]
        IMG4[anomaly-detector:stable]
    end
    
    subgraph "Deployment Target"
        DC[Docker Compose]
        S1[demo-app]
        S2[otel-collector]
        S3[prometheus]
        S4[tempo]
        S5[grafana]
        S6[anomaly-detector]
    end
    
    W1 --> W2
    W2 --> GHCR
    GHCR --> IMG1
    GHCR --> IMG2
    W3 --> GHCR
    GHCR --> IMG3
    GHCR --> IMG4
    W3 --> DC
    DC --> S1
    DC --> S2
    DC --> S3
    DC --> S4
    DC --> S5
    DC --> S6
    
    style W1 fill:#e1f5ff
    style W2 fill:#fff4e1
    style W3 fill:#f0e1ff
    style GHCR fill:#ffe1e1
    style DC fill:#e1ffe1
```

---

## Rollback Strategy

```mermaid
graph TB
    A[Deployment Starts] --> B{Smoke Tests}
    B -->|Pass| C[Tag as Stable]
    B -->|Fail| D[Trigger Rollback]
    
    D --> E[Stop Current Deployment]
    E --> F[Pull Stable Images]
    F --> G[Redeploy Stable Version]
    G --> H[Verify Health]
    H --> I{Healthy?}
    I -->|Yes| J[Rollback Complete]
    I -->|No| K[Manual Intervention]
    
    C --> L[Continue to Production]
    
    style D fill:#ffe1e1
    style E fill:#ffe1e1
    style F fill:#fff4e1
    style G fill:#fff4e1
    style J fill:#e1ffe1
    style K fill:#ffe1e1
```

---

## Monitoring Points

```mermaid
graph LR
    A[Pipeline Start] --> B[CI Tests]
    B --> C[Docker Build]
    C --> D[Deployment]
    D --> E[Smoke Tests]
    E --> F[Production]
    
    B -.->|Metrics| M1[Test Coverage]
    C -.->|Metrics| M2[Build Time]
    D -.->|Metrics| M3[Deploy Time]
    E -.->|Metrics| M4[Test Results]
    F -.->|Metrics| M5[Uptime]
    
    M1 --> Dashboard[GitHub Actions Dashboard]
    M2 --> Dashboard
    M3 --> Dashboard
    M4 --> Dashboard
    M5 --> Dashboard
    
    style Dashboard fill:#e1ffe1
```

---

## Referencias

- **Workflows:** [README.md](README.md)
- **Documentación:** [../../CI-CD-IMPLEMENTATION.md](../../CI-CD-IMPLEMENTATION.md)
- **Quick Start:** [../../QUICK-START-CI-CD.md](../../QUICK-START-CI-CD.md)
