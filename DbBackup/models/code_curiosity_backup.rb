# encoding: utf-8

##
# Backup Generated: code_curiosity_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t code_curiosity_backup [-c <path_to_configuration_file>]
#
BACKUP = YAML.load_file('backup.yml')

Backup::Model.new(:code_curiosity_backup, 'Description for code_curiosity_backup') do
  ##
  # MongoDB [Database]
  #
  database MongoDB do |db|
    db.name               = BACKUP['database']['name']
    db.username           = ""
    db.password           = ""
    db.host               = BACKUP['database']['host']
    db.port               = 27017
    db.ipv6               = false
    db.only_collections   = []
    db.additional_options = []
    db.lock               = false
    db.oplog              = false
  end

  ##
  # Amazon Simple Storage Service [Storage]

  store_with S3 do |s3|
    # AWS Credentials
    s3.access_key_id     = BACKUP['storage']['s3_access_key_id']
    s3.secret_access_key = BACKUP['storage']['s3_secret_access_key']
    # Or, to use a IAM Profile:
    # s3.use_iam_profile = true

    s3.region            = BACKUP['storage']['region']
    s3.bucket            = BACKUP['storage']['bucket']
    #s3.path             = "/backups"
    s3.keep              = 5
    # s3.keep            = Time.now - 2592000 # Remove all backups older than 1 month.
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
    encryption.keys[BACKUP['encryptor']['mail']] = <<-KEY
    KEY

    # Specify mode (:asymmetric, :symmetric or :both)
    encryption.mode = :asymmetric # defaults to :asymmetric

    # Specify recipients from #keys (for :asymmetric encryption)
    encryption.recipients = BACKUP['encryptor']['mail']

    # Specify passphrase or passphrase_file (for :symmetric encryption)
    encryption.passphrase =  BACKUP['encryptor']['passphrase']
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

    mail.from                 = BACKUP['notify']['from']
    mail.to                   = BACKUP['notify']['to']
    mail.address              = "smtp.gmail.com"
    mail.port                 = 587
    mail.domain               = BACKUP['notify']['domain']
    mail.user_name            = BACKUP['notify']['user_name']
    mail.password             = BACKUP['notify']['password']
    mail.authentication       = BACKUP['notify']['authentication']
    mail.encryption           = :starttls
  end
end
