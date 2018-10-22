import argparse
import json
import os
import urllib
import urllib2


base_url = 'http://{}/api'
regions_path = '/dcim/regions/'
sites_path = '/dcim/sites/'
manufacturers_path = '/dcim/manufacturers/'
platforms_path = '/dcim/platforms/'
device_roles_path = '/dcim/device-roles/'


def make_request(path, address, token, data=None):
    url = "{}{}".format(base_url.format(address), path)
    headers = {
        'Authorization': "Token {}".format(token),
        'Content-Type': "application/json",
        'Accept': "application/json",
    }
    if data is not None:
        data = json.dumps(data)
    request = urllib2.Request(url, data, headers)
    try:
        response = urllib2.urlopen(request)
    except Exception as e:
        print(e.read())
    return json.loads(response.read())


def get_object_count(path, address, token):
    result = make_request(path, address, token)
    return result.get('count', 0)


def post_objects(path, address, token, data):
    result = make_request(path, address, token, data)
    return result


def load_data(address, token):

    locate = lambda x: os.path.abspath(os.path.join(os.path.dirname(__file__), x))

    with open(locate("fixtures/regions.json"), "r") as f:
        regions = json.load(f)

    if get_object_count(regions_path, address, token) != len(regions):
        post_objects(regions_path, address, token, regions)

    with open(locate("fixtures/sites.json"), "r") as f:
        sites = json.load(f)

    if get_object_count(sites_path, address, token) != len(sites):
        post_objects(sites_path, address, token, sites)

    with open(locate("fixtures/manufacturers.json"), "r") as f:
        manufacturers = json.load(f)

    if get_object_count(manufacturers_path, address, token) != len(manufacturers):
        post_objects(manufacturers_path, address, token, manufacturers)

    with open(locate("fixtures/platforms.json"), "r") as f:
        platforms = json.load(f)

    if get_object_count(platforms_path, address, token) != len(platforms):
        post_objects(platforms_path, address, token, platforms)

    with open(locate("fixtures/device_roles.json"), "r") as f:
        device_roles = json.load(f)

    if get_object_count(device_roles_path, address, token) != len(device_roles):
        post_objects(device_roles_path, address, token, device_roles)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Populate data into NetBox via the API.')
    parser.add_argument(
        'address',
        type=str,
        help='NetBox instance address',
    )
    parser.add_argument(
        'token',
        type=str,
        help='NetBox instance API token',
    )
    args = parser.parse_args()
    load_data(args.address, args.token)
