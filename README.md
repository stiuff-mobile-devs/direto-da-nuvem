# Direto da Nuvem

Aplicativo Flutter de sinalização digital para Android TV, voltado à comunicação institucional da Universidade Federal Fluminense. Transmissão de imagens e vídeos em múltiplos dispositivos, organizados em grupos e gerenciados via interface administrativa mobile/web pela Superintendência de Comunicação Social.

🌐 [Acesse o site](https://direto-da-nuvem.web.app)  
📱 [Baixe na Play Store](https://play.google.com/store/apps/details?id=br.uff.diretoDaUff)  
🧪 [Participe do Beta](https://play.google.com/apps/testing/br.uff.diretoDaUff)  

## Funcionalidades

- **Autenticação**: Autenticação com Google usando conta institucional.
- **Gerenciamento de dispositivos**:
  - Registrar dispositivos.
  - Vincular dispositivos a grupos.
- **Gerenciamento de filas**:
  - Criar filas temáticas.
  - Adicionar imagens a filas.
  - Configurar animações de transição.
  - Definir duração.
  - Sistema de moderação.
- **Gerenciamento de grupos**:
  - Criar grupos.
  - Definir administradores.
  - Vincular filas a grupos.
- **Privilégios baseados em papéis**:
  - Superadmin: acesso a todos os grupos e a moderação de filas.
  - Admin: acesso aos grupos administrados.
  - Instalador: registra e vincula dispositivos a grupos.

## Estrutura do projeto

```
lib/
│
├── controllers/   # Regras de negócio e gerenciamento de estado
├── models/        # Entidades
├── services/      # Integração a serviços externos (Firebase, Storage, Auth)
├── views/         # Componentes e lógica da UI
├── utils/         # Utilitários e helpers
```
