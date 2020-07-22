resource "null_resource" "publicip"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.wordpress.public_ip} > publicip.txt"
  	}
}

resource "null_resource" "privateip"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.mysql.private_ip} > privateip.txt"
  	}
}

resource "null_resource" "nulllocal1"  {
	provisioner "local-exec" {
	    command = "start chrome  ${aws_instance.wordpress.public_ip}"
  	}
	  depends_on = [
    aws_instance.wordpress
	aws_instance.mysql
  ]
}

output "wordpressid"{
  value=aws_instance.wordpress.id
}

output "mysqlid"{
  value=aws_instance.mysql.id
}

output "eipid"{
  value=aws_eip.nat.id
}

output "eipprivateip"{
  value=  aws_eip.nat.private_ip
}

output "eippublicip"{
  value=  aws_eip.nat.public_ip
}