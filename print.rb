def print(x)
    #puts x
end

def gera(tipo_campo, parametros, campo_ref) 
#
#   tipo:campo
#       - :email; :email:campo_ref
#       - :senha; :senha:campo_ref
#       - :fone; :fone:
#       - :data
#       - :cpf
#       - :inteiro:número_algarismos
#       - :real:parte_inteira;parte_decimal
#
    if tipo_campo == 'email'
        if campo_ref != nil
            nome = parametros[campo_ref.to_i] 
            valor = nome + "@gmail.com"
        else
            valor = "www@gmail.com"
        end
    elsif tipo_campo == 'senha'
        if campo_ref != nil
            nome = parametros[campo_ref.to_i]
            valor =  nome + "123"
        else
            valor =  "senha123"
        end
    elsif tipo_campo == 'phone'
        prefixo = 11 + Random.rand(88)
        prefixo += 1 if (prefixo % 10) == 0
        prefixo = prefixo.to_s
        numero = '9'
        for n in 1..8 do
            numero = numero + Random.rand(9).to_s
        end
        valor = prefixo + numero
    elsif tipo_campo == 'data'
        dia = (1 + Random.rand(27)).to_s
        mes = (1 + Random.rand(11)).to_s
        ano =  (1950 + Random.rand(70)).to_s
        valor = dia + '/' + mes + '/' + ano
    else
        puts "tipo campo inválido: #{tipo_campo}"   
        valor = ""
    end 
    dbg "Gera --- #{valor}"
    return valor
end
#   gera
