# Be sure to restart your server when you modify this file.

# 1-hour sessions are specified in the PSAP Software Requirements Specification
Psap::Application.config.session_store :cookie_store, key: '_psap_session',
                                       expire_after: 1.hour
