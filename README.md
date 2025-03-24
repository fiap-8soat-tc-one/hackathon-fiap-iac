# Arquitetura AWS para o Hackathon FIAP 🚀

Este documento tem como objetivo apresentar e justificar a escolha das tecnologias utilizadas na arquitetura proposta para o Hackaton da FIAP. Cada serviço da AWS e componente de infraestrutura foi selecionado com base em critérios de escalabilidade, segurança, integração, facilidade de operação e aderência a um cenário realista e moderno de aplicações cloud-native.

Abaixo, detalhamos o funcionamento, vantagens e comparações com soluções concorrentes para cada tecnologia adotada, destacando os diferenciais da AWS para garantir uma entrega eficiente, segura e escalável.

## Amazon EKS ☸️

### O que é

O Amazon Elastic Kubernetes Service (EKS) é o serviço gerenciado de Kubernetes da AWS, que elimina a necessidade de manter manualmente o control plane e permite escalar clusters com segurança, integração e resiliência.

### Por que foi escolhido

- Reduz complexidade operacional com plano de controle gerenciado
- Alta disponibilidade automática entre zonas (Multi-AZ)
- Suporte a workloads em EC2, Fargate e Graviton
- Segurança granular com IAM e IRSA (roles por pod)
- Observabilidade integrada com CloudWatch

### Trade-offs

| Plataforma | Prós | Trade-offs |
|------------|------|------------|
| EKS (AWS) | Altamente integrado, seguro, pronto para produção | Custo do plano de controle, curva de aprendizado |
| AKS (Azure) | Boa integração com DevOps e AD | Menos flexível para redes customizadas |
| GKE (Google) | Avançado em automação e upgrades | Preço elevado, vendor lock-in |
| K8s on-prem | Total controle | Elevado custo de operação |

## Amazon Cognito 🔐

### O que é

Serviço de autenticação e gerenciamento de usuários que oferece suporte nativo a login social, autenticação multifator (MFA), customização de fluxo com triggers e escalabilidade automática.

### Por que foi escolhido

- Integração nativa com API Gateway e IAM
- Autenticação via email/senha ou provedores sociais (OAuth)
- Suporte a MFA e políticas de senha
- Custos controlados por número de usuários ativos

### Comparativo

| Plataforma | Prós | Trade-offs |
|------------|------|------------|
| Cognito (AWS) | Serverless, IAM nativo, escalável | Complexidade inicial |
| Auth0 | Interface amigável, fácil de usar | Alto custo em escala |
| Firebase Auth | Simples e rápido para apps móveis | Pouco flexível para requisitos enterprise |
| Azure AD B2C | Robustez e SSO | Curva de configuração longa |

## Amazon API Gateway 🌐

### O que é

Serviço gerenciado para criar e expor APIs REST, HTTP e WebSocket com recursos integrados como autenticação, versionamento e throttling.

### Por que foi escolhido

- Fácil integração com Lambda, Cognito e VPC
- Controle de acesso por chave, JWT ou IAM
- Suporte a CORS, caching, deploys automatizados
- Custo sob demanda, por requisição

### Comparativo

| Plataforma | Prós | Trade-offs |
|------------|------|------------|
| API Gateway (AWS) | Nativo, serverless, integrado com IAM | Curva inicial e limitação de throughput em planos básicos |
| Kong | Open-source, personalizável | Precisa ser hospedado e gerenciado |
| Apigee (GCP) | Completo para grandes empresas | Complexidade e custo |
| Azure API Management | Completo e integrado ao AD | Requer tuning fino |

## Amazon DynamoDB 🗃️

### O que é

Banco de dados NoSQL serverless com latência de milissegundos, billing por requisição e escalabilidade horizontal automática.

### Por que foi escolhido

- Alta disponibilidade e performance consistente
- Sem necessidade de provisionamento de instâncias
- Recursos como TTL, Streams e índices secundários
- Ideal para cargas com leitura/escrita intensa e imprevisível

### Comparativo

| Plataforma | Prós | Trade-offs |
|------------|------|------------|
| DynamoDB (AWS) | Serverless real, baixo custo operacional | Consultas limitadas por chave, sem joins |
| MongoDB Atlas | Consultas flexíveis | Precisa gerenciar escalabilidade |
| CosmosDB | Multi-modelos e replicação global | Mais caro |
| Firebase Firestore | Foco em apps mobile | Limitação em filtros e modelagem |

## Amazon SQS 📩

### O que é

Serviço de mensageria assíncrona totalmente gerenciado com suporte a filas padrão (best-effort) e FIFO (ordenação garantida).

### Por que foi escolhido

- Ideal para desacoplar componentes (ex: uploads e processamento)
- Integração nativa com S3 e Lambda
- Simples de operar, escalável, seguro com IAM

### Comparativo

| Plataforma | Prós | Trade-offs |
|------------|------|------------|
| SQS (AWS) | Escalável, confiável, baixo custo | Latência maior do que brokers em tempo real |
| RabbitMQ | Ordenação, TTL, plugins | Requer servidores e manutenção |
| Kafka | Streaming de eventos em larga escala | Complexidade de setup |
| Azure Queue | Simples e básico | Poucos recursos avançados |

## Amazon ECR 🐳

### O que é

Repositório privado de imagens Docker gerenciado, com integração direta ao ECS, EKS e CodePipeline.

### Por que foi escolhido

- Login via IAM (sem credenciais expostas)
- Scan de vulnerabilidade automático
- Alta integração com pipelines CI/CD AWS
- Escalabilidade nativa e billing por armazenamento

### Comparativo

| Plataforma | Prós | Trade-offs |
|------------|------|------------|
| ECR (AWS) | Seguro, automatizável, IAM nativo | Pode ter custo superior a repositórios públicos |
| DockerHub | Popular e gratuito (limitado) | Limite de pull e segurança frágil |
| GitHub Container Registry | Prático para devs GitHub | Menos controle granular de permissões |
| GCR / ACR | Integrado à GCP/Azure | Limitado fora de seus ecossistemas |

## AWS Lambda ⚙️

### O que é

AWS Lambda é um serviço de computação serverless que permite executar código em resposta a eventos, sem precisar provisionar ou gerenciar servidores. O código pode ser acionado por eventos de diversos serviços da AWS, como S3, DynamoDB, API Gateway, SQS, entre outros.

### Por que foi escolhido

- Elimina a necessidade de gerenciar infraestrutura para execução de funções simples
- Excelente para processamento de eventos (upload de arquivos, callbacks, validações)
- Alta integração com quase todos os serviços AWS
- Escala automaticamente conforme a demanda
- Modelo de cobrança por invocação e tempo de execução (pay-per-use)

### Exemplos de uso no projeto

- Processamento automático após upload de arquivos em um bucket S3
- Validação de dados recebidos via API Gateway
- Comunicação com DynamoDB ou envio de mensagens ao SQS

### Comparativo

| Plataforma           | Prós                                          | Trade-offs                                |
|----------------------|-----------------------------------------------|--------------------------------------------|
| Lambda (AWS)         | Serverless real, escalável, altamente integrado | Cold start em linguagens como Java         |
| Cloud Functions (GCP)| Fácil de usar, integração com Firebase        | Menos granularidade de controle            |
| Azure Functions      | Boa integração com Azure Logic Apps           | Requer atenção ao setup de networking      |
| OpenFaaS / Knative   | Flexível, pode ser usado on-prem              | Requer gerenciamento e provisionamento     |

## Conclusão 📘

A arquitetura foi desenhada com foco em boas práticas de microsserviços, segurança, resiliência e facilidade de automação. Cada componente da AWS foi selecionado por sua integração nativa, confiabilidade e adesão ao modelo serverless, reduzindo custos operacionais e acelerando o desenvolvimento.

Com essa fundação moderna e escalável, a equipe do Hackaton da FIAP poderá focar em inovação e entrega de valor, sem se preocupar com a complexidade da infraestrutura.
