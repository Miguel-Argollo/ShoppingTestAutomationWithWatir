#
#   Script para execução de testes de sistemas de um sistema de compras online
#   com a biblioteca Watir
#
#       - 

#
#	export PATH=$PATH:/home/miguel/Documentos/WorkArea/Projetos/Watir/LojaOnline:

require 'watir'
require 'roo'
require './print.rb'
Watir.default_timeout = 10

endereco_aplicativo = "automationpractice.com"
$pr_planilha="Planilha_Testes"

$ntestes=0		# casos de teste efetivamente realizados
$npastas=0		# pastas da planilha de teste 
$nerros=0			# situacoes onde resultado obtido difere do resultado esperado
$nbloqueados=0	# situacoes nas quais casos de teste nao foram executados (normalmente por problemas na IG)

#	Mensagens

Msg_sucesso=   "     Caso de teste nao detectou falha"
Msg_falha=        "     Caso de teste detectou falha"
Msg_bloqueado="     Caso de teste bloqueado"
endereco_aplicativo = "automationpractice.com"

def le_parametros(arq_parametros)
#
#	Le o arquivo "parametros.txt" que se encontra no diretorio do aplicativo de automacao.
#	Este arquivo contem os valores do parametros que controlam a execucao do 
#	framework de automacao:
#	-  Navegador [opcional:firefox]: nome do navegador utilizado - firefox ou chrome
#	- VM [obrigatorio]  m�quina virtual utilizada nos testes
#	- Arquivo: [ opcional: Planilha_testes.ods]: planilha com os casos de teste utilizados
#	- Log: [opcional: INFO] - nivel do log do sistema 
#	- Delay [Opcional: 1] - numero de segundos que o framework espera ao final da execu��o de um teste
#	- MostrarResultados[Opcional: 0] - numero de segundos que o framework exibe os campos preenchidos antes de seu processamento
# - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - - 

	File.open(arq_parametros, 'r') do |registro|
		while linha=registro.gets
			puts "       #{linha.chomp}"
			next if (linha[0] == "#") or (linha[0]==nil)
			
			vet=linha.split"=>"
			par=vet[0]
			valor=vet[1].chomp
			
			if par == "Navegador"
				if valor == "chrome"
					$pr_navegador=:chrome
				elsif valor == "firefox" or valor == "ff"
					$pr_navegador=:firefox
				else 
					relatorio "Navegador invalido - abrindo chrome"
					$pr_navegador=:chrome
				end
				
			elsif par == "VM"
				$pr_maquina_virtual=valor
			elsif par == "Log"
				$nivel_log=valor
			elsif par == "Delay"
				$delay_comandos=valor.to_i
			elsif par == "MostraResultados"
				$show_results=valor.to_i
			elsif par == "Arquivo"
				temp=valor.split":"
				$pr_planilha=temp[0]
				if temp.length == 2
					$pasta_teste=temp[1]
				else
					$pasta_teste=nil
				end
				puts $pr_planilha
			elsif par == "DR"
					$RelatDir=$RelatDir + "/" + valor
					puts "Diretorio: #{$RelatDir}"
				#$pr_planilha=valor
			end
				
		end
	end
    
end
# 	le_parametros

def relatorio(linha, cor=nil)
#
#	Imprime o par�metro na tela e no arquivo de relat�rios; pensar em alterar para imprimir em cares em caso de
#	erro detectado (em vermelho) ou teste bloqueado (em amarelo) em ambiente Linux.
#
# - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - - 
 
    linha_utf8=linha.to_s.encode("UTF-8")
    if cor == :yellow
        puts linha #.yellow
    elsif cor == :red
        puts linha #.red
    else
        puts linha
    end
    $pt_arquivo_relatorio.write(linha_utf8+"\n") if $pr_relatorio==true
    #$pt_arquivo_relatorio.write(linha+"\n") if $pr_relatorio==true
end
# 	relatorio

def dbg(linha_trace)

	puts linha_trace

end
#	dbg

def visualizarIG(segundos)
#
#	Interrompe o processamento do script pelo número de segundos indicado pelo parâmetro,
#	facilitando a visualização das ações efetuadas na interface gráfica do aplicitivo
#	em teste
#
	sleep segundos

end 
#	visualizarIG

def abre_aplicacao(endereco_app)
	#
	#	Abre a versao em teste do sistema no ambiente de homologacao
	#	Pontos em aberto:
	#
	# - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - - 
 
    $browser = Watir::Browser.new
    $browser.instance_variable_set :@speed, :slow
    $browser.goto endereco_app
	$browser.driver.manage.window.maximize
    visualizarIG 1
    
    #	informa versão & revis�o da aplicativo em teste]
        
end
#	abre_aplicacao

def executa_teste(parametros)
	#
	#	Desvia para a rotina responsavel pelo processamento de cada comando da planilha de testes.
	#	O tratamento das eventuais execoes que possam ocorrer e realizado por esta rotina
	#
	# - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - - 
 
 	begin
		comando=parametros[0]
		#puts parametros
		#$log.unknown("#{comando} #{parametros[1]} #{parametros[2]} #{parametros[3]} #{parametros[4]} #{parametros[5]}")
		$ntestes+=1
		
		if comando=="cadastra"
			cadastra(parametros)
		elsif comando == "login"	
			login(parametros)
		elsif comando == "shopping"
			shopping(parametros)
		elsif comando == "escolhe_produto"
			escolhe_produto(parametros)
		elsif comando == "retira_produto"
			retira_produto(parametros)
		elsif comando == "verifica_total_compra"
			verifica_total_compra(parametros)
		elsif comando == "checkout"
			checkout(parametros)
		elsif comando == "logout"
			logout(parametros)

		else
			relatorio "Comando inválido: #{comando}"
		end
#
#	Trata exceções levantadas na execução do framework
#	
	rescue Exception => ex
		relatorio         "     >>>   Erro na execução: #{comando}" #
		puts              "     >>>   Mensagem: [#{ex.message}]"
		$nbloqueados+=1
		#$log.unknown("     >>>   Mensagem: [#{ex.message}]")
		
		msg_excecao=ex.backtrace.inspect 

		#puts "msg_excecao:"
		#puts msg_excecao
		
		vt=msg_excecao.partition('AutomaçãoLojas.rb')	# vt[0], vt[1], vt[2]

		#puts "vt"
		#puts vt[0]
		#puts vt[1]
		#puts vt[2]
		#puts "==========="
		ln=vt[2].split(':')
		#$log.unknown "     >>>   Exceção não tratada na linha: #{ln[1]}"
		relatorio ("     >>>   Exceção não tratada na linha: #{ln[1]}")
		
	ensure	
		#puts "comandos executados"
	end
	# bloco
	
end
#	executa_teste

def processa_testes()
	#
	#	Abre a planilha com os casos de teste e chama a rotina executa_teste
	#	passando como parametro array com dados de teste.
	#	OBS.:
	#		- a planilha deve estar no formato open-office
	#		- processa todas as pastas da planilha que nao comecam com "#"
	#		- linhas que comecam com "#" sao consideradas comentario
	#		- substitui campos que comecam por <nil> pelo valor nulo (nil)
	#		- substitui campos que comecam por <branco> por " "
	#		-a planilha deve se encontrar no diretorio "Testes" localizado um nivel abaixo
	#		  do diretorio onde se encontra o framework de automacao
	#	Pontos em aberto:
	#	- 	a rotina deve ser alterada para controlar grupos de casos de teste
	# - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - - 

	#	Abre a planilha

	relatorio "Arquivo de teste: #{$arquivo_testes}"

	if not File.exists?($arquivo_testes)
		relatorio ("Arquivo #{$arquivo_testes} não existe!")
		exit
	end
	
	plan_testes = Roo::OpenOffice.new($arquivo_testes)   
	relatorio "Existem #{plan_testes.sheets.size} pastas na planilha"
	sheet_number=0
	
#	Percorre pastas da planilha

	plan_testes.sheets.each do |pasta|
		relatorio "Pasta: #{pasta}"
		relatorio " " 
		
		plan_testes.default_sheet = plan_testes.sheets[sheet_number]
		sheet_number+=1
		next if pasta[0] == "#" or plan_testes.first_row == nil
		$npastas+=1
		
		next if $pasta_teste != nil and $pasta_teste != pasta
		
#		Percorre linhas da pasta
		
		(plan_testes.first_row .. plan_testes.last_row).each do |linha|
			parametros=Array.new
			parametros= plan_testes.row(linha)
			relatorio "#{parametros[0]} #{parametros[1]} #{parametros[2]} #{parametros[3]} #{parametros[4]} #{parametros[5]}"
			
			#linha_relatorio=String.new
			parametros.each_index do |ind|
				#linha_relatorio+=parametros[ind].to_s+":"
				break if parametros[ind] == nil
				if parametros[ind].class == Float
					parametros[ind]=parametros[ind].to_i
				end
				parametros[ind]=parametros[ind].to_s
				if parametros[ind].downcase.include? 'gera:'
					dbg '------------------  gera  -----------------'
					pr=parametros[ind].split ':'
					dbg pr
					parametros[ind] = gera(pr[1], parametros, pr[2])
				end

				parametros[ind] = " " if parametros[ind].downcase == "<branco>"
				parametros[ind] = nil if parametros[ind].downcase == "<nil>"
				parametros[ind] = nil if parametros[ind] == "<vazio>"
			end	# 
			
			#relatorio linha_relatorio
			
			comando=parametros[0]
			next if comando == nil
			if parametros[0][0]!="#" or comando == nil
				executa_teste(parametros)
			end	
		end	#	linhas	
	end	#	pasta
	
end
# processa_testes

def valida_teste(elem_erro, elem_op_valida, resultado_esperado)
	#	
	#	Verifica o resultado do teste realizado de acordo com as seguintes informações;
	#	- elem_erro: elemento da IG que ocorre quando o aplicativo detecta uma falha na operação
	#	- elem_op_valida: elemento da IG que ocorre quando o aplicativo não detecta falhas na operação
	#	- resultado_esperado: pode assumir os seguintes valores:
	#		- OP_VALIDA: teste positivo (por ex, cadastro deve ter sido realizado)
	#		- OP_INVALIDA: teste negativo: (por ex, cadastro naõ deve ter sido realizado)
	#
	#	A princípio, cada linha da planilha está associada a um caso de teste
	#
	# - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - -  - - - - - - - - - - - - - - - 

	wait = true
	while wait
		wait = false if elem_erro.exists?
		wait = false if elem_op_valida.exists?
	end

	if (elem_op_valida.exists?)
		if resultado_esperado == "OP_VALIDA"
			relatorio Msg_sucesso
		else
			relatorio Msg_falha #, :red
			$nerros+=1
		end
	else
		if resultado_esperado == "OP_INVALIDA"
			relatorio Msg_sucesso
		else
			relatorio Msg_falha #, :red
			$nerros+=1
		end
	end
		
end	
# valida_teste

def busca_elementos(*args)
#
#	Retorna valores dos tags :id & :name dos elementos text_fields, botons & select_lists existentes 
#	no sistema #	no momento em que a rotina � chamada; �til para preencher os par�metros da 
#	chamadas Watir. 
#
#	Chamada: busca_elementos(:campos_texto, :listas,:botoes)
#
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
    args.each { |parametro|
        
        if parametro == :campos_texto
            $browser.text_fields.each do |el|
            	puts"- - - - -"
            	puts "$browser.text_field(name: \"#{el.name}\").value=parametros[]"
            	puts "$browser.text_field(id: \"#{el.id}\").value=parametros[]"
        	end
            
        elsif parametro == :botoes
            $browser.buttons.each do |el|
            	puts "- - - - -"
            	puts "$browser.button(name: \"#{el.name}\").click"
            	puts "$browser.button(id: \"#{el.id}\").click"
           		puts "$browser.button(text: \"#{el.text}\").click"
        	end
            
        elsif parametro == :listas
            $browser.select_lists.each do |el|
            	puts "- - - - -"
            	puts "$browser.select_list(name: \"#{el.name}\").select parametros[]"
            	puts "$browser.select_list(id: \"#{el.id}\").select parametros[]"
        	end
            
        end
    }	# args
end
#	busca_elementos

def shopping(parametros)
#
#	Testa a operação de ...
#
#	Parâmtros:
#	- [1] - Women, Dresses, T-shirts
#
	#>> dbg "shopping"

end
#	shopping

def escolhe_produto(parametros)
#
#	Escolhe e coloca no Kart produto especificado pelos parâmetros do teste:
#	- [1] - Descrição do item (Printed Dress, Blouse, ...)
#	- [2] - Quantidade a ser comprada
#	- [3] - Tamanho (S, M, L)
#	- [4] - Resultado (OP_VALIDA, OP_INVALIDA)
#
	#>> dbg "escolhe_produto"

	$browser.text_field(id: 'search_query_top'). value=parametros[1]
	$browser.text_field(id: 'search_query_top').send_keys :enter

	$browser.a(title: /#{parametros[1]}/, index: 1).click

	for ind in 1 .. (parametros[2].to_i - 1) do
		$browser.i(class: "icon-plus").click
	end
	$browser.select_list(id: 'group_1').select parametros[3]

	$browser.span(text: "Add to cart").click
	$browser.span(title: "Continue shopping").click

	# sleep 5
	# nprod = $browser.span(class: /ajax_cart_quantity unvisible/).text
	# puts "Produtos no cart: #{nprod}"

	$browser.a(title: "View my shopping cart").fire_event :onmouseover
	Watir::Wait.until {$browser.span(class: /price cart_block_total ajax_block_cart_total/).present? }

	valor_produtos = $browser.span(class: /price cart_block_total ajax_block_cart_total/).text
	#>> puts "Valor dos ítens: #{valor_produtos}"

	visualizarIG 1

end
#	escolhe_produto

def retira_produto(parametros)

	#>> dbg "retira produto"

	$browser.a(title: "View my shopping cart").fire_event :onmouseover
	Watir::Wait.until {$browser.span(class: /price cart_block_total ajax_block_cart_total/).present? }
	$browser.a(class: 'ajax_cart_block_remove_link', index: 0).flash
	$browser.a(class: 'ajax_cart_block_remove_link', index: 0).click

	visualizarIG 5

end
#	retira_produto

def verifica_total_compra(parametros)

	valor_esperado = parametros[1]

	$browser.a(title: "View my shopping cart").fire_event :onmouseover
	Watir::Wait.until {$browser.span(class: /price cart_block_total ajax_block_cart_total/).present? }
	valor_kart = $browser.span(class: /price cart_block_total ajax_block_cart_total/).text

	if valor_esperado == valor_kart
		relatorio Msg_sucesso
	else
		$nerros += 1
		relatorio Msg_falha
	end

end
#	verifica_total_compra

def checkout(parametros)
#
#	Finaliza uma compra dos produtos colocados no cart, informando conta & senha caso não haja usuário logado.
#
#	Parâmetros:
#		[1] - Valor da compra
#		[2] - Conta do usuário ou campo vazio
#		[3] - senha do usuário ou campo vazio
#
#	Validação:
#		. Verifica o valor da compra informado no caso de teste com o valor existente no resumo fornecido
#		  pelo sistema
#		. Verifica o código da operação gerado pelo sistema pelo código existente no resumo fornecido
#		  pelo sistema
#
#	Problemas:
#	
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

	valor_esperado = parametros[1]
#	01 - Summary

	$browser.a(title: "View my shopping cart").fire_event :onmouseover
	Watir::Wait.until {$browser.span(class: /price cart_block_total ajax_block_cart_total/).present? }
	$browser.a(id: 'button_order_cart').click
	#>> puts "01"

#	01 - Summary ---> 03 - Address

	$browser.a(class: /button btn btn-default standard-checkout button-medium/).click #ou $browser.a(title: "Proceed to checkout", index: 1).click
	#>> puts "02"

#	Informa conta & senha caso não haja usuário logado

	if $browser.a(class: "login").exists?
		#>> puts "Usuario não logado"
		sleep 1
		#>> puts "continuando ..."
		$browser.text_field(id: 'email').value = parametros[2]
		$browser.text_field(id: 'passwd').value = parametros[3]

		$browser.button(id: 'SubmitLogin').click
		sleep 1
	end

#	03 - Address ---> 04 - Shipping

	$browser.button(class: /button btn btn-default button-medium/).click 
	#$browser.a(class: "button-exclusive btn btn-default").click
	#>> puts "03"

#	05 - Payment

	$browser.checkbox(name: "cgv").set
	$browser.button(name: "processCarrier").click
	#>> puts "04"

	# $browser.a(class: "bankwire").flash	# cheque
	# $browser.a(class: "bankwire").click

	$browser.a(class: "cheque").flash	# cheque
	$browser.a(class: "cheque").click

	$browser.element(visible_text: "I confirm my order").flash
	$browser.element(visible_text: "I confirm my order").click
	#$browser.button(type: "submit").click
	#>> puts "05"
	visualizarIG 1

#	Verifica resultado do teste

	#puts $browser.text
	html_text = $browser.text
	order_ref = html_text.scan(/order reference (.*)./)[0][0]
	#puts order_ref

#	Verifica lista de ordens geradas para o usuário ligado

	$browser.link(title: "My orders").click
	#puts $browser.table(id: "order-list")[1][0].text	# reference order 
	valor_recuperado = $browser.table(id: "order-list")[1][2].text
	
	if valor_esperado != valor_recuperado
		relatorio Msg_falha + "; valor esperado  #{valor_esperado}, valor gerado #{valor_recuperado}"
		$nerros+=1
	else
		relatorio Msg_sucesso
	end
end
#	checkout
		
def cadastra(parametros)
#
#	Testa a operação de cadastro um novo usuário no sistema
#
#	Parâmetros:
#		[1] - email do usuário
#		[2] - nome inicial do usuário
#		[3] - sobrenome do usuário
#		[4] - senha
#		[5] - data do nascimento: dd/mm/aaaa
#		[6] - newsletter (True)
#		[7] - ...
#		[8] - firstname 	[ ??? ]
#		[9]	- lastname		[ ??? ]
#		[10] - companhia	[ ??? ]
#		[11] - address1
#		[12] - address2
#		[13] - cidade
#		[14] - Estado (1, 2, 3, ...)
#		[15] - código postal
#		[16] - comentario
#
#	Validação:
#		. Senha já utilizada
#		. Campos com valores incorretos
#	
#	Problemas:
#		
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

	resultado_teste = parametros[20]	# OP_VALIDA , OP_INVALIDA
	$browser.a(class: 'login').click

	Watir::Wait.until { $browser.text_field(id: 'email_create').exists?}
	$browser.text_field(id: 'email_create').value= parametros[1] # gera(:email, parametros, 2)
	sleep 5
	$browser.button(id: 'SubmitCreate').click

#	Verifica a ocorrência de erro

	elem_erro = $browser.div(id: "create_account_error")
	elem_op_valida = $browser.text_field(id: 'customer_firstname')

	wait = true
	while wait
		wait = false if elem_erro.present?		
		wait = false if elem_op_valida.present?	
	end

	if elem_erro.present?						
		relatorio Msg_falha #, :red
		$nerros+=1
		return
	end

#	Preenche informações do novo usuário

	Watir::Wait.until { $browser.text_field(id: 'customer_firstname').present? }
	$browser.text_field(id: 'customer_firstname').value=parametros[2]
	$browser.text_field(id: 'customer_lastname').value=parametros[3] 
	$browser.text_field(id: 'passwd').value = parametros[4]
	data=parametros[5].split('/')
	$browser.select_list(id: 'days').select (data[0])   # ((1+Random.rand(30)).to_s) ##(data[0])
	$browser.select_list(id: 'months').select (data[1]).delete_prefix "0"  # ((1+Random.rand(11)).to_s) #(/#{data[1]}/) 
	$browser.select_list(id: 'years').select(data[2])
	$browser.checkbox(id: 'newsletter').set if parametros[6] == 'True'
	$browser.checkbox(id: 'optin').set if parametros[7] == 'True'
	$browser.text_field(id: 'firstname').value= parametros[8]
	$browser.text_field(id: 'lastname').value= parametros[9]
	$browser.text_field(id: 'company').value= parametros[10]
	$browser.text_field(id: 'address1').value= parametros[11]
	$browser.text_field(id: 'address2').value= parametros[12]
	$browser.text_field(id: 'city').value= parametros[13]
	$browser.select_list(id: 'id_state').select(/#{parametros[14]}/)
	$browser.text_field(id: 'postcode').value= parametros[15]
	$browser.textarea(id: 'other').set parametros[16]
	$browser.text_field(id: 'phone').value=parametros[17]
	$browser.text_field(id: 'phone_mobile').value=parametros[18]
	$browser.text_field(id: 'alias').value=parametros[19]

	$browser.button(id: 'submitAccount').click

	elem_erro = $browser.div(class: /alert alert-danger/)
	elem_op_valida = $browser.p(class: 'info-account')

	valida_teste(elem_erro, elem_op_valida, resultado_teste)

end
#	cadastra

def login(parametros)
#
#	Testa a operação de cadastro um novo usuário no sistema
#
#	Parâmetros:
#		[1] - email do usuário
#		[2] - senha do usuário
#		[3] - resultado do teste - OP_VALIDA, OP_INVALIDA
#
#	Validação:
#		. email e senha não associadas
#	
#	Problemas:
#		
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

#	Faz logout se houver usuário logado

	if $browser.a(class: 'logout').exists?
		$browser.a(class: 'logout').click
	end

	Watir::Wait.until { $browser.a(class: 'login').exists?}
	$browser.a(class: 'login').click

#	Preenche campos email & senha

	Watir::Wait.until { $browser.text_field(id: 'email').exists?}
	$browser.text_field(id: 'email').value = parametros[1]
	$browser.text_field(id: 'passwd').value = parametros[2]

	$browser.button(id: 'SubmitLogin').click

#	Verifica o resultado do teste

	elem_erro = $browser.div(class: /alert alert-danger/)
	elem_op_valida = $browser.div(class: 'shopping_cart')
	resultado_teste = parametros[3]

	valida_teste(elem_erro, elem_op_valida, resultado_teste)
	visualizarIG 1
end
#	login

def logout(parametros)
#
#	Realiza a operação de logout
#
#	Parâmetros:
#		. não há parâmetros associados
#
#	Validação:
#		. não há nenhuma validação para essa operação
#	
#	Problemas:
#		
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

	if $browser.a(class: 'logout').exists?
		$browser.a(class: 'logout').click
	end

end

#	logout

#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
#

t1=Time.now
system_directory=File.expand_path(File.dirname(__FILE__))

#puts system_directory
puts "Arquivo do script: #{$0}"
le_parametros("parametros.txt")
#puts $pr_planilha
$arquivo_testes= File.expand_path(File.dirname(__FILE__))+"/Cenarios/" + $pr_planilha +".ods"
#puts $arquivo_testes

#	Abre o navegador e inicia o teste

abre_aplicacao(endereco_aplicativo)

#	Inicia os testes

relatorio "Início dos testes"
relatorio " "
processa_testes

#	Calcula tempo de teste & imprime resultados consolidados

t2=Time.now
relatorio " "
relatorio         "Shopping - final do processamento - #{Time.now}"
#$log.unknown("Shopping - final do processamento - #{Time.now}")
relatorio         "Número de testes realizados: #{$ntestes} em #{$npastas} pastas."
#$log.unknown("Número de testes realizados: #{$ntestes} em #{$npastas} pastas.")
relatorio         "Número de erros detectados:  #{$nerros}"
#$log.unknown("Número de erros detectados:  #{$nerros}")
relatorio         "Número de testes bloqueados: #{$nbloqueados}"
#$log.unknown("Número de testes bloqueados: #{$nbloqueados}")

segundos = (t2-t1).to_i   
segundo = segundos % 60;   
minutos = segundos / 60;   
minuto = minutos % 60;   
hora = minutos / 60;   

hms = "%02d:%02d:%02d" % [hora, minuto, segundo]
relatorio "Tempo de processamento: #{hms}"

puts "Digite algo para fechar o navegador"
$stdout.flush
x = STDIN.getc
puts "Fechando o navegador ..."
visualizarIG 2

print("*********         Final dos testes         *********")
