"""
Run this in a NetBox venv as it uses the ORM directly
"""
import random
import string

from dcim.models import Site, Device, Role, Platform, DeviceType


def load_data(count):
    device_types = DeviceType.objects.all()
    device_type_count = DeviceType.objects.count()
    sites = Site.objects.all()
    sites_count = Site.objects.count()
    roles = Role.objects.all()
    roles_count = Role.objects.count()
    platforms = Platform.objects.all()
    platforms_count = Platform.objects.count()

    letters = string.ascii_letters

    devices = []
    for _ in range(0, count):
        device_type = device_types[random.randint(0, device_type_count - 1)]
        site = site[random.randint(0, sites_count - 1)]
        platform = platforms[random.randint(0, platforms_count - 1)]
        role = roles[random.randint(0, roles_count - 1)]

        name = ''.join(random.choice(letters) for i in range(10))

        device = Device.objects.create(
            name=name,
            site=site,
            platform=platform,
            role=role,
            device_type=device_type
        )


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Populate devices based on count using the ORM')
    parser.add_argument(
        'count',
        type=int,
        help='Device count',
    )
    args = parser.parse_args()
    load_data(args.count)
