import boto3

bucketname = "my-unique-bucket-name"
s3 = boto3.resource('s3')
my_bucket = s3.Bucket(bucketname)
source = "path/to/folder1"
target = "path/to/folder2"

for obj in my_bucket.objects.filter(Prefix=source):
    source_filename = (obj.key).split('/')[-1]
    copy_source = {
        'Bucket': bucketname,
        'Key': obj.key
    }
    target_filename = "{}/{}".format(target, source_filename)
    s3.meta.client.copy(copy_source, bucketname, target_filename)
    # Uncomment the line below if you wish the delete the original source file
    # s3.Object(bucketname, obj.key).delete()
