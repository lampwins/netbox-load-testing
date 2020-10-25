import random
import string

from dcim.models import Site, Device, DeviceRole, Platform, DeviceType
from extras.scripts import *


class LoadTestingDevicesScript(Script):

    class Meta:
        name = "Load Testing Bulk Devices"
        description = "Generate bulk devices for load testing"

    device_count = IntegerVar(
        description="Number of devices to create"
    )

    def run(self, data, commit):

        count = data['device_count']

        device_types = DeviceType.objects.all()
        device_type_count = DeviceType.objects.count()
        sites = Site.objects.all()
        sites_count = Site.objects.count()
        roles = DeviceRole.objects.all()
        roles_count = DeviceRole.objects.count()
        platforms = Platform.objects.all()
        platforms_count = Platform.objects.count()

        letters = string.ascii_letters

        devices = []
        for _ in range(0, count):
            device_type = device_types[random.randint(0, device_type_count - 1)]
            site = sites[random.randint(0, sites_count - 1)]
            platform = platforms[random.randint(0, platforms_count - 1)]
            role = roles[random.randint(0, roles_count - 1)]

            name = ''.join(random.choice(letters) for i in range(10))

            device = Device.objects.create(
                name=name,
                site=site,
                platform=platform,
                device_role=role,
                device_type=device_type
            )
