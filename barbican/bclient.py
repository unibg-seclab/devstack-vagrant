#!/usr/bin/env python

import sys
import traceback

from barbicanclient import client
from keystoneclient import session
from keystoneclient.auth import identity
from connection import *


def main():

    try:
       # We'll use Keystone API v3 for authentication
        auth = identity.v2.Password(auth_url=AUTH_URL,
            username=ADMIN_USER,
            password=ADMIN_PASS,
            tenant_name=ADMIN_TENANT)

        # Next we'll create a Keystone session using the auth plugin we just created
        sess = session.Session(auth=auth)

        print 'session created successfully'

        # Now we use the session to create a Barbican client
        barbican = client.Client(endpoint=BARB_URL, session=sess)

        print 'barbican client created successfully'

        # Let's create a Secret to store some sensitive data
        secret = barbican.secrets.create(name=u'Self destruction sequence',
                                         payload=u'the magic words are squeamish ossifrage')

        print 'secret created successfully'

        # Now let's store the secret by using its store() method. This will send the secret data
        # to Barbican, where it will be encrypted and stored securely in the cloud.
        secret.store()
        #u'http://localhost:9311/v1/secrets/85b220fd-f414-483f-94e4-2f422480f655'

        print 'secret stored successfully'

        # The URI returned by store() uniquely identifies your secret in the Barbican service.
        # After a secret is stored, the URI is also available by accessing
        # the secret_ref attribute.
        print(secret.secret_ref.replace('localhost',
            AUTH_IP))
        #http://localhost:9311/v1/secrets/091adb32-4050-4980-8558-90833c531413

        # When we need to retrieve our secret at a later time, we can use the secret_ref
        retrieved_secret = barbican.secrets.get(secret.secret_ref.replace('localhost',
            AUTH_IP))
        # We can access the secret payload by using the payload attribute.
        # Barbican decrypts the secret and sends it back.
        print(retrieved_secret.payload)
        #the magic words are squeamish ossifrage

    except:
        traceback.print_exc(file=sys.stdout)


if __name__ == '__main__':
	main()
