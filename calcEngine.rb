#CANNOT HAVE SPACES IN INPUT (!!!)
#INVALID INPUTS ARE NOT ALLOWED examples: ("-", "4+")


class CalculatorEngine
    def calculate(calculation)
        consume = 0;#value doesn't matter here

        #Tokenizer parses, and creates tokens for evaluation
        tokens, consume = tokenizer(calculation, 0)

        #print tokens
        #middleMan will group the higher precedence operators such that they are calculated correctly.
        tokens = middleMan(tokens)

        #puts "after middleMan: #{tokens}"

        #Evaluates the tokenized expression
        result = evaluate(tokens)


        return result
    end

    def tokenizer(s, i)
        localTokens = []
        n = s.length
        need_value = true
        #Iterate Thru STR
        while i < n
            c = s[i]
            if c == ')'
                i += 1
                return [localTokens, i]
            end
            #CHECK IF C IS DIGIT (=~) or OPERATOR and if it needs a digit
            #Handle Negative Values Here
            if c =~ /\d/ || (c == '-' && need_value)
                sign = 1
                if c == '-'
                    i += 1
                    #start of group expression
                    if s[i] == '('
                        localTokens << ["num", -1, "*"]
                        inner, i = tokenizer(s, i + 1)
                        # attach 
                        if i < n && "+-*/%".include?(s[i])
                            localTokens << ["group", inner, s[i]]
                            i += 1
                        else
                            localTokens << ["group", inner, "N"]
                        end

                        need_value = false
                        
                        next
                    end
                    sign = -1
                end

                # read digits --------------DECIMAL SUPPORT----------
                num = ""
                #Sentinal Variable For later
                decimal = false

                while i < n && (s[i] =~ /\d/ || (s[i] == '.' && !decimal))
                if s[i] == '.'
                    #decimal is true, we must set as float for storage to avoid truncation
                    decimal = true
                end
                    num << s[i]
                    i += 1
                end

                value = 0

                if decimal == true
                    #Make Sure Value is a float, avoid truncation
                    value = num.to_f
                else
                    value = num.to_i
                end
                # read digits  ---------------------------------

                localTokens << ["num", sign * value, nil]

                if i < n && s[i] == '('
                    localTokens[-1][2] = "*"
                    #RECURSE, NEW STATEMENT TO TOKENIZE
                    inner, i = tokenizer(s, i + 1)
                    if i < n && "+-*/%".include?(s[i])
                        localTokens << ["group", inner, s[i]]
                        i += 1
                    else
                        localTokens << ["group", inner, "N"]
                    end
                    need_value = false
                    next
                end

                if i < n && "+-*/%".include?(s[i])
                    localTokens[-1][2] = s[i]
                    i += 1
                    need_value = true
                else
                    localTokens[-1][2] = "N"
                    need_value = false
                end
                #Starting of Expression is parenthis
            elsif c == '('
                inner, i = tokenizer(s, i + 1)
                localTokens << ["group", inner, nil]

                if i < n && "+-*/%".include?(s[i])
                    localTokens[-1][2] = s[i]
                    i += 1
                    need_value = true
                else
                    #endlol (-1 means to push from end)
                    localTokens[-1][2] = "N"
                    need_value = false
                end
            end
        end
        [localTokens, i]
    end


    # PRESIDENCE WITHOUT PARENTHESIS
    def middleMan(tokens)
        localTokens = []
        i = 0

        while i < tokens.length
            token = tokens[i]

            if token[0] == 'group'
                # Recurse inside parentheses (grouped expressions)
                grouped = middleMan(token[1])
                localTokens << ["group", grouped, token[2]]

            elsif ['*', '/'].include?(token[2])
                # Detected Higher Precedence
                left  = token
                right = tokens[i+1]
                i += 1 


                #Creation of new group for evaluator
                newGroup = [
                    "group",
                    [
                        [left[0], left[1], left[2]],
                        [right[0], right[1], 'N']
                    ],
                    right[2] || 'N'
                ]

                #Add the new grouped token to the tokens
                localTokens << newGroup
            else
                #Handles % case, as it's not distributive.
                #also handles trivial + and - 
                localTokens << token
            end

            i += 1
        end

        return localTokens
    end



    #EVALUATE TOKENIZED EXPRESSION
def evaluate(tokens)
    res = 0
    x = 0
    #Initialize prevToken to nil
    prevToken = nil

    for token in tokens do
        #Check Token Type
        if token[0] == 'group'
            #Recurse To find value of group  (parenthesis)
            value = evaluate(token[1])
            #Check if we are on first token, x doesn't matter after that
            if x == 0
                #Start of tokenized expression
                res = value
            else
                #Operations
                if prevToken[2] == '+'
                    res += value
                elsif prevToken[2] == '-'
                    res -= value
                elsif prevToken[2] == '*'
                    res *= value
                elsif prevToken[2] == '/'
                    #DIVIDE BY ZERO ERROR
                    if value == 0
                        return "CANNOT DIVIDE BY 0"
                    else
                        res = res.to_f / value.to_f
                    end
                elsif prevToken[2] == '%'
                    if value == 0
                        return "CANNOT MODULO BY 0"
                        
                    else
                        res = res.to_f - value.to_f * (res.to_f / value.to_f).floor
                        res = res.round(10)
                    end
                elsif prevToken[2].nil? || prevToken[2] == 'N'
                    # Implicit multiplication
                    res *= value
                end
            end

        elsif token[0] == 'num'
            value = token[1]
            #Check if we are on first token, x doesn't matter after that
            if x == 0
                res = value
            else
                #Operations
                if prevToken[2] == '+'
                    res += value
                elsif prevToken[2] == '-'
                    res -= value
                elsif prevToken[2] == '*'
                    res *= value
                elsif prevToken[2] == '/'
                    #DIVIDE BY 0 Condition
                    if value == 0
                        return "CANNOT DIVIDE BY 0"
                    else
                        res = res.to_f / value.to_f
                    end
                elsif prevToken[2] == '%'
                    if value == 0
                        return "CANNOT MODULO BY 0"
                    else
                        res = res.to_f - value.to_f * (res.to_f / value.to_f).floor
                        res = res.round(10)
                    end
                #Evaluating two Grouped expressions, or one grouped and one numbered
                elsif prevToken[2].nil? || prevToken[2] == 'N'
                    res *= value
                end
            end
        end
        #Keep Track of Prevous Token for Calculation of expression
        prevToken = token
        x += 1
    end

    return res
end

end
