\# E-Commerce API



API de E-Commerce desenvolvida em \*\*C# com \[ASP.NET](http://ASP.NET) Core\*\* como projeto da disciplina de Desenvolvimento de Software.



\## 📋 Sobre o Projeto



Uma API RESTful completa para gerenciamento de um e-commerce, incluindo catálogo de produtos, autenticação, carrinho de compras e integração com gateway de pagamento.



\## 🛠️ Tecnologias



\- \[\*\*ASP.NET](http://ASP.NET) Core Web API\*\* — Framework principal

\- \*\*Entity Framework Core\*\* — ORM

\- \*\*SQL Server\*\* — Banco de dados

\- \*\*Swagger / OpenAPI\*\* — Documentação interativa da API

\- \*\*JWT\*\* — Autenticação

\- \*\*Stripe\*\* — Gateway de pagamento

\- \*\*xUnit\*\* — Testes (opcional)



\## 🚀 Como Rodar



```bash

\# Clone o repositório

git clone https://github.com/seu-usuario/ecommerce-api.git



\# Entre na pasta do projeto

cd ecommerce-api/ECommerceAPI



\# Restaure as dependências

dotnet restore



\# Aplique as migrations

dotnet ef database update



\# Rode a aplicação

dotnet run

```



Acesse o Swagger em `https://localhost:{porta}/swagger` para testar os endpoints.



\## 📁 Estrutura do Projeto



```

ECommerceAPI/

├── Controllers/        → Endpoints da API

├── Models/             → Entidades de domínio

├── Data/               → DbContext e configurações do EF Core

├── DTOs/               → Objetos de transferência de dados

├── Services/           → Lógica de negócio

├── Migrations/         → Migrations do EF Core

└── Program.cs          → Configuração da aplicação

```



\## 📌 Funcionalidades Planejadas



\- \[ ]  \*\*Catálogo de Produtos\*\* — CRUD completo + busca por nome/descrição

\- \[ ]  \*\*Autenticação JWT\*\* — Registro, login e controle de acesso por roles

\- \[ ]  \*\*Carrinho de Compras\*\* — Adicionar, editar e remover itens

\- \[ ]  \*\*Checkout com Stripe\*\* — Pagamento integrado com gateway externo



\## 📅 Roadmap de Entregas



| Entrega | Prazo | Escopo |

| --- | --- | --- |

| AC1 | 15/03 | Catálogo de Produtos + Busca |

| AC2 | ~04/04 | Autenticação JWT + Painel Admin |

| AC3 | 10/05 | Carrinho de Compras |

| Prova | 07/06 | Checkout + Pagamento Stripe |



\## 🧪 Testes



Utilize o \*\*Swagger\*\* para testar os endpoints diretamente no navegador ou o \*\*Postman\*\* para validação manual.



\## 📝 Licença



Projeto acadêmico — uso educacional.

