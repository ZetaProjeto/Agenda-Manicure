# Agenda de manicure — GitHub Pages + Supabase

## O que faz
- Calendário com data selecionável e horários disponíveis (09:00 a 17:00, segunda a sábado).
- Reserva persistente compartilhada, com bloqueio de duplicidade no banco.
- Formulário com nome, WhatsApp, serviço e observações.
- Mensagem pronta para envio pelo WhatsApp da manicure, **após** salvar a reserva.
- Os nomes e telefones não são retornados ao público; somente horários ocupados.

## Configuração
1. Crie um projeto em https://supabase.com e abra **SQL Editor**.
2. Cole todo o conteúdo de `supabase.sql` e execute.
3. Em **Project Settings > API** (ou **Connect**, conforme interface) obtenha o `Project URL` e a chave **publishable/anon**, nunca `service_role`.
4. Abra `config.js` e preencha `supabaseUrl`, `supabaseAnonKey`, `whatsappResponsavel` (ex.: `5511999999999`) e nome do salão. Edite serviços se quiser.
5. Crie um repositório no GitHub e envie `index.html`, `style.css`, `script.js`, `config.js` (o SQL e README podem ficar no repositório).
6. Em **Settings > Pages**, escolha **Deploy from a branch**, `main`, `/ (root)`.

## Importante antes de divulgar
- Envio de WhatsApp **não é automático**: a cliente abre uma conversa com texto pronto e precisa enviar. Para envio automático sem clique, use backend/Edge Function + API oficial do WhatsApp com credenciais privadas e autorização apropriada.
- O horário selecionado só está definitivamente reservado quando o Supabase confirmar a inserção. Duas reservas simultâneas são impedidas pelo índice único.
- A agenda inicial usa **blocos fixos de 1 hora** para todos os serviços. Se serviços tiverem duração diferente, altere a modelagem para impedir sobreposição de intervalos.
- Em uso público real, acrescente antispam/rate limiting/CAPTCHA validado no servidor; o endpoint público pode receber reservas falsas e o exemplo não oferece painel de cancelamento.
- Respeite a LGPD: informe política de privacidade, base legal, prazo de retenção e canal de solicitação de exclusão. Restrinja o acesso ao painel Supabase.
- A lista de horários é atualizada ao mudar a data e quando a aba recebe foco. Durante a abertura, confirme que o horário desejado ainda está livre.
- O painel do dono inicialmente é o **Table Editor do Supabase**, não um painel administrativo público.
