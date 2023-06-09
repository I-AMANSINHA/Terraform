############################################# Create VPC ####################################################

resource "aws_vpc" "terra_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
   "Name" = "terra-vpc"
  }
}

########################################### Create Internet Gateway ########################################

resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
   "Name" = "terra-igw"
  }
}

########################################### NAT Gateway ####################################################

resource "aws_nat_gateway" "terra_natgw" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.terra_subnet.id
}

resource "aws_eip" "terra_eip" {
  vpc = true
}
########################################### Create Route Table ##############################################

resource "aws_route_table" "terra_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
    Name = "terra-rt"
  }
}

resource "aws_route_table" "terra_pvt_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.terra_natgw.id
  }
  tags = {
    Name = "terra-pvt-rt"
  }
}


############################################ Associate Route Table with Subnet #################################

resource "aws_route_table_association" "terra_rta" {
  subnet_id = aws_subnet.terra_subnet.id
  route_table_id = aws_route_table.terra_rt.id
}

resource "aws_route_table_association" "terra_pvt_rt" {
  subnet_id = aws_subnet.terra_pvt_subnet.id
  route_table_id = aws_route_table.terra_pvt_rt.id
}
############################################ Create Subnet #####################################################

resource "aws_subnet" "terra_subnet" {
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "terra-subnet1"
  }
}

resource "aws_subnet" "terra_pvt_subnet" {
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "terra-subnet2"
  }
}

########################################### create SG ##########################################################

resource "aws_security_group" "terra_sg" {
  name_prefix = "terra-sg"

 ingress {
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

