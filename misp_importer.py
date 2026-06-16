import os
import re
import json

try:
    from pymisp import PyMISP, MISPEvent
except ImportError:
    print("Por favor, instale o pymisp executando: pip install pymisp")
    exit(1)

# Desabilita os warnings de certificado SSL (útil se estiver usando HTTPS local sem certificado válido)
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Configurações do MISP
MISP_URL = 'https://localhost'
MISP_KEY = 'QgfzXTEil9dEJsvIT4rBISE8Ya2iG5TsT6HWDvwl' #Ta hardcoded mesmo e fodase 
MISP_VERIFYCERT = False

print("Conectando ao MISP...")
try:
    misp = PyMISP(MISP_URL, MISP_KEY, MISP_VERIFYCERT)
except Exception as e:
    print(f"Erro ao conectar ao MISP. Verifique se ele está rodando e se a URL/Chave estão corretas.\nDetalhes: {e}")
    exit(1)

def import_kippo(log_path):
    print(f"\n--- Processando logs do Kippo: {log_path} ---")
    if not os.path.exists(log_path):
        print("Arquivo não encontrado.")
        return
    with open(log_path, 'r', encoding='utf-8') as f:
        for line in f:
            match = re.search(r'\] (.*)', line)
            ip_match = re.search(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b', line)
            if ip_match and match:
                ip = ip_match.group()
                action = match.group(1).strip()
                
                event = MISPEvent()
                event.info = f"Kippo: {action}"
                event.distribution = 0 # Sua Organização apenas
                event.threat_level_id = 3 # Low
                event.analysis = 2 # Análise Concluída
                
                event.add_attribute('ip-src', ip, comment="Atacante SSH capturado pelo Kippo")
                
                misp.add_event(event)
                print(f"[+] Evento criado: {event.info} (IP: {ip})")

def import_snort(log_path):
    print(f"\n--- Processando logs do Snort: {log_path} ---")
    if not os.path.exists(log_path):
        print("Arquivo não encontrado.")
        return
    with open(log_path, 'r', encoding='utf-8') as f:
        for line in f:
            desc_match = re.search(r'\] (.+?) \[\*\*\]', line)
            ips_match = re.findall(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b', line)
            
            if desc_match and len(ips_match) >= 2:
                desc = desc_match.group(1).strip()
                src_ip = ips_match[0]
                dst_ip = ips_match[1]
                
                event = MISPEvent()
                event.info = f"Snort: {desc}"
                event.distribution = 0
                event.threat_level_id = 2 # Medium
                event.analysis = 2
                
                event.add_attribute('ip-src', src_ip, comment="IP de Origem do Ataque")
                event.add_attribute('ip-dst', dst_ip, comment="IP Alvo (Sua Rede)")
                
                misp.add_event(event)
                print(f"[+] Evento criado: {event.info} (Origem: {src_ip})")

def import_dionaea(log_path):
    print(f"\n--- Processando logs do Dionaea: {log_path} ---")
    if not os.path.exists(log_path):
        print("Arquivo não encontrado.")
        return
    with open(log_path, 'r', encoding='utf-8') as f:
        for line in f:
            if not line.strip():
                continue
            try:
                data = json.loads(line.strip())
                protocol = data.get('connection_protocol', 'Desconhecido').upper()
                
                event = MISPEvent()
                event.info = f"Dionaea: Malware Distribuído via {protocol}"
                event.distribution = 0
                event.threat_level_id = 1 # High (Malware capturado é alta ameaça)
                event.analysis = 2
                
                if 'src_ip' in data:
                    event.add_attribute('ip-src', data['src_ip'], comment="IP Distribuidor do Malware")
                if 'md5' in data:
                    event.add_attribute('md5', data['md5'], comment="Hash MD5 do payload")
                if 'sha256' in data:
                    event.add_attribute('sha256', data['sha256'], comment="Hash SHA256 do payload")
                    
                misp.add_event(event)
                print(f"[+] Evento criado: {event.info} (MD5: {data.get('md5')})")
            except json.JSONDecodeError:
                pass

if __name__ == '__main__':
    print("==============================================")
    print("   IMPORTANDO TODOS OS EVENTOS MISP OOPSNET   ")
    print("==============================================")
    
    # Executa a leitura de todos os logs e envia pro MISP
    import_kippo(r'd:\oopsnet\logs\kippo\kippo.log')
    import_snort(r'd:\oopsnet\logs\snort\alert_fast.txt')
    import_dionaea(r'd:\oopsnet\logs\dionaea\dionaea.json')
    
    print("\n[+] Importação finalizada com sucesso! Verifique a aba 'Eventos' no MISP.")
