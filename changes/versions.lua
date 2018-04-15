local Event = require('event')
return {
    ['2.0.2'] = function()
        local msg = 'Autofill upgraded to version 2.0.2, Forcing full reset'
        log(msg)
        game.print(msg)
        Event.dispatch({name = Event.core_events.init})
    end
}
