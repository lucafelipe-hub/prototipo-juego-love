-- =================== DECLARACION ===================
local jugador = {}
local enemigo = {}
local coleccionable = {}
local balas = {}

local estadoJuego = "jugando"
local puntuacion = 0
local objetivoPuntos = 5

local imagenAvion = nil
local imagenEnemigo = nil

local sonidoCoin = nil
local sonidoDisparo = nil
local sonidoDerrota = nil
local sonidoVictoria = nil

-- =================== INICIALIZACION ===================
function love.load()
    jugador.x = 400
    jugador.y = 300
    jugador.ancho = 32
    jugador.alto = 32
    jugador.velocidad = 250

    enemigo.x = 100
    enemigo.y = 100
    enemigo.ancho = 30
    enemigo.alto = 30
    enemigo.velocidad = 100

    coleccionable.x = math.random(100, 700)
    coleccionable.y = math.random(100, 500)
    coleccionable.radio = 10

    sonidoCoin = love.audio.newSource("coin.mp3", "static")
    sonidoDisparo = love.audio.newSource("disparo.mp3", "static")
    sonidoDerrota = love.audio.newSource("derrota.mp3", "static")
    sonidoVictoria = love.audio.newSource("victoria.mp3", "static")

    imagenAvion = love.graphics.newImage("avion.png")
    imagenEnemigo = love.graphics.newImage("enemigo.png")
end

-- =================== INTERACCION ===================
function love.mousepressed(x, y, button, istouch, presses)
    if estadoJuego == "jugando" and button == 1 then
        if sonidoDisparo then
            sonidoDisparo:stop()
            sonidoDisparo:seek(7, "seconds")
            sonidoDisparo:play()
        end

        local centroJugadorX = jugador.x + jugador.ancho / 2
        local centroJugadorY = jugador.y + jugador.alto / 2

        local angulo = math.atan2(y - centroJugadorY, x - centroJugadorX)
        local velocidadBala = 500

        table.insert(balas, {
            x = centroJugadorX,
            y = centroJugadorY,
            vx = math.cos(angulo) * velocidadBala,
            vy = math.sin(angulo) * velocidadBala,
            radio = 4
        })
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    
    if (estadoJuego == "victoria" or estadoJuego == "derrota") and key == "r" then
        reiniciarJuego()
    end
end

-- =================== ACTUALIZACION ===================
function love.update(dt)
    if estadoJuego == "jugando" then
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            jugador.x = jugador.x + (jugador.velocidad * dt)
        end
        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            jugador.x = jugador.x - (jugador.velocidad * dt)
        end
        if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
            jugador.y = jugador.y + (jugador.velocidad * dt)
        end
        if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
            jugador.y = jugador.y - (jugador.velocidad * dt)
        end

        if jugador.x < 0 then jugador.x = 0 end
        if jugador.x > 800 - jugador.ancho then jugador.x = 800 - jugador.ancho end
        if jugador.y < 0 then jugador.y = 0 end
        if jugador.y > 600 - jugador.alto then jugador.y = 600 - jugador.alto end

        if enemigo.x < jugador.x then enemigo.x = enemigo.x + (enemigo.velocidad * dt)
        elseif enemigo.x > jugador.x then enemigo.x = enemigo.x - (enemigo.velocidad * dt) end

        if enemigo.y < jugador.y then enemigo.y = enemigo.y + (enemigo.velocidad * dt)
        elseif enemigo.y > jugador.y then enemigo.y = enemigo.y - (enemigo.velocidad * dt) end

        for i = #balas, 1, -1 do
            local b = balas[i]
            b.x = b.x + b.vx * dt
            b.y = b.y + b.vy * dt

            if b.x < 0 or b.x > 800 or b.y < 0 or b.y > 600 then
                table.remove(balas, i)
            else
                local colisionBalaEnemigo = b.x < enemigo.x + enemigo.ancho and
                                            b.x + b.radio > enemigo.x and
                                            b.y < enemigo.y + enemigo.alto and
                                            b.y + b.radio > enemigo.y

                if colisionBalaEnemigo then
                    table.remove(balas, i)
                    enemigo.x = math.random(50, 750)
                    enemigo.y = math.random(50, 550)
                end
            end
        end

        local colisionColeccionable = jugador.x < coleccionable.x + coleccionable.radio and
                                      jugador.x + jugador.ancho > coleccionable.x - coleccionable.radio and
                                      jugador.y < coleccionable.y + coleccionable.radio and
                                      jugador.y + jugador.alto > coleccionable.y - coleccionable.radio

        if colisionColeccionable then
            puntuacion = puntuacion + 1
            if sonidoCoin then sonidoCoin:play() end
            coleccionable.x = math.random(50, 750)
            coleccionable.y = math.random(50, 550)
        end

        local colisionEnemigo = jugador.x < enemigo.x + enemigo.ancho and
                                jugador.x + jugador.ancho > enemigo.x and
                                jugador.y < enemigo.y + enemigo.alto and
                                jugador.y + jugador.alto > enemigo.y

        if colisionEnemigo then
            estadoJuego = "derrota"
            if sonidoDerrota then sonidoDerrota:play() end
        end

        if puntuacion >= objetivoPuntos then
            estadoJuego = "victoria"
            if sonidoVictoria then sonidoVictoria:play() end
        end
    end
end

function reiniciarJuego()
    jugador.x = 400
    jugador.y = 300
    enemigo.x = 100
    enemigo.y = 100
    puntuacion = 0
    balas = {}
    estadoJuego = "jugando"
    coleccionable.x = math.random(100, 700)
    coleccionable.y = math.random(100, 500)
end

-- =================== RENDERIZADO ===================
function love.draw()
    if estadoJuego == "jugando" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Puntuación: " .. puntuacion .. " / " .. objetivoPuntos, 20, 20)
        love.graphics.print("Clic izquierdo para disparar hacia el mouse", 20, 40)

        if imagenAvion then
            local escalaX = jugador.ancho / imagenAvion:getWidth()
            local escalaY = jugador.alto / imagenAvion:getHeight()
            love.graphics.draw(imagenAvion, jugador.x, jugador.y, 0, escalaX, escalaY)
        else
            love.graphics.setColor(0.2, 0.6, 1)
            love.graphics.rectangle("fill", jugador.x, jugador.y, jugador.ancho, jugador.alto)
        end

        if imagenEnemigo then
            local escalaX = enemigo.ancho / imagenEnemigo:getWidth()
            local escalaY = enemigo.alto / imagenEnemigo:getHeight()
            love.graphics.draw(imagenEnemigo, enemigo.x, enemigo.y, 0, escalaX, escalaY)
        else
            love.graphics.setColor(0.9, 0.2, 0.2)
            love.graphics.rectangle("fill", enemigo.x, enemigo.y, enemigo.ancho, enemigo.alto)
        end

        love.graphics.setColor(1, 0, 0)
        for _, b in ipairs(balas) do
            love.graphics.circle("fill", b.x, b.y, b.radio)
        end

        love.graphics.setColor(0.2, 0.9, 0.3)
        love.graphics.circle("fill", coleccionable.x, coleccionable.y, coleccionable.radio)

        love.graphics.setColor(1, 1, 1)

    elseif estadoJuego == "victoria" then
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.print("¡VICTORIA! Presiona 'R' para reiniciar", 250, 250)
        love.graphics.setColor(1, 1, 1)

    elseif estadoJuego == "derrota" then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.print("¡DERROTA! Presiona 'R' para reiniciar", 250, 250)
        love.graphics.setColor(1, 1, 1)
    end
end