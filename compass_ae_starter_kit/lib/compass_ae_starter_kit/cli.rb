Signal.trap("INT") { puts; exit(1) }

require 'compass_ae_starter_kit/commands/compass_ae'

CompassAeStarterKit::CompassAE.run
