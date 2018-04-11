# encoding: utf-8

##
# Backup Generated: code_curiosity_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t code_curiosity_backup [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://backup.github.io/backup
#

BACKUP = YAML.load_file('config/backup.yml')['backup_data']

Model.new(:code_curiosity_backup, 'Description for code_curiosity_backup') do

  ##
  # MongoDB [Database]
  #
  database MongoDB do |db|
    db.name               = BACKUP['database_name']
    db.username           = ""
    db.password           = ""
    db.host               = BACKUP['database_host']
    db.port               = 27017
    db.ipv6               = false
    db.only_collections   = []
    db.additional_options = []
    db.lock               = false
    db.oplog              = false
  end

  ##
  # Amazon Simple Storage Service [Storage]
  #
  store_with S3 do |s3|
    # AWS Credentials
    s3.access_key_id     = BACKUP['s3_access_key_id']
    s3.secret_access_key = BACKUP['s3_secret_access_key']
    # Or, to use a IAM Profile:
    # s3.use_iam_profile = true

    s3.region            = "ap-southeast-1"
    s3.bucket            = "codecuriosity"
    #s3.path              = "/backups"
    s3.keep              = 5
    # s3.keep              = Time.now - 2592000 # Remove all backups older than 1 month.
  end

  ##
  # GPG [Encryptor]
  #
  # Setting up #keys, as well as #gpg_homedir and #gpg_config,
  # would be best set in config.rb using Encryptor::GPG.defaults
  #
  encrypt_with GPG do |encryption|
    # Setup public keys for #recipients
    encryption.keys = {}
    encryption.keys['user@domain.com'] = <<-KEY
      -----BEGIN PGP PUBLIC KEY BLOCK-----
      Version: GnuPG v1.4.11 (Darwin)
      
      mQENBFq4/RUBCACrmhrL6EBOruu3OaYhzggDgxCw9f77r1Y/XS4OmU/PTtr8NGAe
      TAoTffwoNZmdi3LQ3AfFlj1egSZnxu3wP0NYpjg/PMZz3yF8DFPQ+OXbZM7hqMio
      j/+FPVWy8KURrZuZRiP2PolqZP9K376R7iK0ZenNqlFjBwwJoUbMRgacxzyXRbFR
      DY1TVGXqdykkeLL8ExtZCc6fdFIIMo90/wEjp+GjKWbP9O+8qw9UaZ3sQNTndxxS
      sgDgJJunAMEKDk/03l2JpGQgpqPwOs/t95fjWHAVSh+52b4CHsvkP+48UDNjZ0GG
      mbF54zdti3eOZ0zvMAlaHh9WOmbnUjOvySU5ABEBAAG0LiJSYWh1bCBKYWRoYXYi
      IChwYWluKSA8cmFodWwucmo5NDIxQGdtYWlsLmNvbT6JATgEEwECACIFAlq4/RUC
      GwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEM3HGI/JkrsDEecH/2SUO2/m
      VT1jLR4WyZnlgrGZFLHv9HVaOFvaRGGSPqP5+t84wXNSWY0f3JI/77bY0msCCQfb
      zBJEzN5T8ljeu+RVWB+PgGY3LM4Pq5hpKOF5g8aeKiOCqWOjxu8Ly15cq24V7WbF
      l1swF+Lp+AaF5LF6/sICinKbr0aWO4g3Gx5Gwyqhfi6a3VHI8sBHxLmPqY2QwqS+
      cEtQdtVHhdTEgaElt/uOK0TO2tfMsK2NIV/ZohFqAVwsTMoF2mo5EwqKyZ4ZTKWl
      KHGjMx84vsuemBEyJB7kEjYNmCZ+CKj0DwEDhfooWKQHmZvB+dKn/GcQYgMJyGQj
      4cRO6ySPPLa5ymq5AQ0EWrj9FQEIAMC4om0eAZFOia34pL8whzX9D4Jb85srtcS4
      vrRJaaNhDTJi2T0B+WzK7qTJGs3pQm9cMfn7zxDwWp0cJ+qrE0yCYWP9TtaXckFf
      DPM73HIDbuMraFQ25/jCi4zWzSvNVi0J8f7p9aGWBoqHOzYpViwnqiX+55uBVgZn
      mckfqZLMxzJNQRtOAEWFzXdzaqEJdTuQDpHDGPWmbiZ1xCgWSrc+51zO+P7cAX4x
      qfHITyEviITb7MSAvOoXqwicE4cc0CjuFSnnNSQxBI/BieZqWpJoDO4RX1RiIv/9
      DCjyvt8GDJIqr38G/EdkN2QMEP0KHjQ/Al2CtbnuhakmgFAQGZ8AEQEAAYkBHwQY
      AQIACQUCWrj9FQIbDAAKCRDNxxiPyZK7A9gDB/9gdxT+rNAp00wgSc+vUgQgUBn7
      +wKZXl543ultH9KP22zEc4iXaiLbr+3lQiYbNnGDyPmGfCYcYReX9zwbOzN+VsV8
      ckYoCx9WOl74HtI802hiFfrokU8lyKECi9IjolRQZbNThn9Px5/1DkflHlvFwYH4
      lrT3ospW429+UJRQErRAP3OXFNCNvwVsTgQtpdRKRTqICpmdBXLwH7cRU3tBuLTS
      K0oAIrATXt1QUju3/XWiPFddBhGj5Hv2SBp5ElYT1sOPmzEM6v4xhzhP9WDyzv7/
      DtpjtchTeUxPcW3HIA5GUpS52Dq3DbtDOHIgqxIIDP2uIHaE2CSdAbbbPkYy
      =m0Pv
      -----END PGP PUBLIC KEY BLOCK-----
    KEY

    # Specify mode (:asymmetric, :symmetric or :both)
    encryption.mode = :both # defaults to :asymmetric

    # Specify recipients from #keys (for :asymmetric encryption)
    encryption.recipients = BACKUP['mail_username']

    # Specify passphrase or passphrase_file (for :symmetric encryption)
    encryption.passphrase = 'a secret'
    # encryption.passphrase_file = '~/backup_passphrase'
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the documentation for other delivery options.
  #
  notify_by Mail do |mail|
    mail.on_success           = true
    mail.on_warning           = true
    mail.on_failure           = true

    mail.from                 = BACKUP['mail_from']
    mail.to                   = BACKUP['mail_to']
    mail.cc                   = "cc@email.com"
    mail.bcc                  = "bcc@email.com"
    mail.reply_to             = "reply_to@email.com"
    mail.address              = "smtp.gmail.com"
    mail.port                 = 587
    mail.domain               = "your.host.name"
    mail.user_name            = BACKUP['mail_username']
    mail.password             = BACKUP['mail_password']
    mail.authentication       = "plain"
    mail.encryption           = :starttls
  end

end
