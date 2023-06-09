#################################### Define private instance ##############################

resource "aws_instance" "private_instance" {
  ami                    = "from aws instance ami"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.terra_subnet.id
  tags = {
    Name = "private-instance"
  }
}
