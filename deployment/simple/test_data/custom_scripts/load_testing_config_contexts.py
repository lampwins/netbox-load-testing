import random
import string

from dcim.models import Site, Device, DeviceRole, Platform, Region
from extras.models import ConfigContext
from extras.scripts import *


types = {
    1: {
        "a": 1,
        "b": 2,
        "c": 3
    },
    2: {
        "a": 2,
        "d": {
            "a": 1
        }
    },
    3: {
        "b": {
            "a": {
                "b": {
                    "c": {
                        "d": {
                            "e": {
                                "f": 1
                            }
                        }
                    }
                }
            }
        }
    },
    4: {
        "b": {
            "a": {
                "b": {
                    "c": {
                        "d": {
                            "e": {
                                "f": 2
                            }
                        }
                    }
                }
            },
            "g": {
                "h": 1
            }
        }
    }
}


class LoadTestingConfigContextsScript(Script):

    class Meta:
        name = "Load Testing Bulk Config Contexts"
        description = "Generate bulk config contexts for load testing"

    config_context_count = IntegerVar(
        description="Number of config contexts to create"
    )

    def run(self, data, commit):

        count = data['config_context_count']

        sites = Site.objects.all()
        sites_count = Site.objects.count()
        roles = DeviceRole.objects.all()
        roles_count = DeviceRole.objects.count()
        platforms = Platform.objects.all()
        platforms_count = Platform.objects.count()
        regions = Region.objects.all()
        regions_count = Region.objects.count()

        letters = string.ascii_letters

        devices = []
        for _ in range(0, count):
            site = sites[random.randint(0, sites_count - 1)]
            platform = platforms[random.randint(0, platforms_count - 1)]
            role = roles[random.randint(0, roles_count - 1)]
            region = regions[random.randint(0, regions_count - 1)]

            data = types[random.randint(1, 4)]
            assignment_choice = random.randint(0, 3)
            name = ''.join(random.choice(letters) for i in range(10))

            config_context = ConfigContext.objects.create(
                name=name,
                weight=random.randint(1, 1001),
                data=data
            )

            if assignment_choice == 0:
                config_context.regions.add(region)
            elif assignment_choice == 1:
                config_context.sites.add(site)
            elif assignment_choice == 2:
                config_context.platforms.add(platform)
                config_context.roles.add(role)
