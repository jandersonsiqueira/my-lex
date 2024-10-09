from quart import Quart, request, jsonify
import google.generativeai as genai
import markdown
import os
import aiofiles

app = Quart(__name__)

# Configure sua chave de API do Gemini
genai.configure(api_key=os.getenv('GEMINI_API_KEY'))

# Função para converter texto Markdown em HTML
def converter_texto_para_html_markdown(texto):
    return markdown.markdown(texto)

async def carregar_contexto_padrao():
    try:
        # Especifica a codificação como 'utf-8'
        async with aiofiles.open('app/contexto_padrao.txt', mode='r', encoding='utf-8') as f:
            contexto = await f.read()
        return contexto.strip()
    except Exception as e:
        print(f"Erro ao carregar o contexto padrão: {e}")
        return ""

# Carrega o contexto padrão quando o servidor estiver pronto para servir
@app.before_serving
async def before_serving():
    global contexto_padrao
    contexto_padrao = await carregar_contexto_padrao()

# Endpoint para o chat
@app.route('/chat', methods=['POST'])
async def chat():
    data = await request.get_json()
    pergunta = data.get('pergunta')
    
    # Gera uma resposta da IA com base no contexto padrão
    resposta = await obter_resposta(pergunta, contexto_padrao)
    
    return jsonify({"resposta": resposta})

# Função para gerar a resposta da IA usando o modelo Gemini
async def obter_resposta(pergunta, contexto_padrao):
    try:
        # Instancia o modelo Gemini
        model = genai.GenerativeModel('gemini-1.5-flash')
        
        # Cria o prompt com o contexto padrão e a pergunta do usuário
        prompt = f"{contexto_padrao}\n\nUser: {pergunta}\nModel:"
        
        # Gera o conteúdo usando a API da Gemini
        response = model.generate_content(prompt)
        resposta_texto = response.text.strip()
        
        return resposta_texto
    except Exception as e:
        print(f"Erro ao acessar a API Gemini: {e}")
        return "Desculpe, ocorreu um erro ao processar sua pergunta."

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True)