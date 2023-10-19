
resource ibm_is_vpc hub_true {
	name = "${var.name}-vpc-hub-true"
	dns {
		enable_hub = true
	}
}

resource ibm_is_vpc hub_false_delegated {
	# resource_group  	=  data.ibm_resource_group.rg.id
	name = "${var.name}-vpc-hub-false-delssss"
	dns {
		enable_hub = false
		resolver {
			type = "delegated"
			vpc_id = ibm_is_vpc.hub_true.id
		}
		# resolver {
		# 	type = "system"
		# 	vpc_id = "null"
		# }
	}
}


# data "ibm_is_vpc_dns_resolution_bindings" "is_vpc_dns_resolution_bindings" {
# 	vpc_id = ibm_is_vpc_dns_resolution_binding.dnstrue.vpc_id
# 	# id = "id"
# }

# resource "ibm_is_virtual_endpoint_gateway" "endpoint_gateway" {
# 	name = "${var.name}-egtruehub"
# 	target {
# 		name          = "ibm-ntp-server"
# 		resource_type = "provider_infrastructure_service"
# 	}
# 	vpc = ibm_is_vpc.hub_true.id
# 	allow_dns_resolution_binding = true
# }

data "ibm_resource_group" "rg" {
	is_default	   =  true
}

# data ibm_is_vpc tgis {
# 	name = ibm_is_vpc.hub_true.name
# }
# data ibm_is_vpcs tgis1 {
# 	resource_group = data.ibm_resource_group.rg.id
# 	# name = "tfp-test-vpc-hub-false-del"
# }
# data ibm_is_vpc tgis1 {
# 	name = "tfp-test-vpc-hub-false-del"
# }
# data ibm_is_vpc tgis12 {
# 	name = "${var.name}-vpc-manual"
# }
# data ibm_is_vpc tgis13 {
# 	name = "${var.name}-vpc-manual-zone"
# }


resource "ibm_is_subnet" "hub_true_sub1" {
	# resource_group  	=  data.ibm_resource_group.rg.id

	name		   				=  "hub-true-subnet1"
	vpc      	   				=  ibm_is_vpc.hub_true.id
	zone		   				=  "${var.region}-2"
	total_ipv4_address_count 	= 16
}
resource "ibm_is_subnet" "hub_true_sub2" {
	# resource_group  	=  data.ibm_resource_group.rg.id
	name		   				=  "hub-true-subnet2"
	vpc      	   				=  ibm_is_vpc.hub_true.id
	zone		   				=  "${var.region}-2"
	total_ipv4_address_count 	= 16
}
resource "ibm_is_subnet" "hub_false_delegated_sub1" {
	# resource_group  	=  data.ibm_resource_group.rg.id
	name		   				=  "hub-false-delegated-subnet1"
	vpc      	   				=  ibm_is_vpc.hub_false_delegated.id
	zone		   				=  "${var.region}-2"
	total_ipv4_address_count 	= 16
}
resource "ibm_is_subnet" "hub_false_delegated_sub2" {
	# resource_group  	=  data.ibm_resource_group.rg.id
	name		   				=  "hub-false-delegated-subnet2"
	vpc      	   				=  ibm_is_vpc.hub_false_delegated.id
	zone		   				=  "${var.region}-2"
	total_ipv4_address_count 	= 16
}
resource "ibm_resource_instance" "dns-cr-instance" {

	name		   		=  "dns-cr-instance"
	resource_group_id  	=  data.ibm_resource_group.rg.id
	location           	=  "global"
	service		   		=  "dns-svcs"
	plan		   		=  "standard-dns"
}
resource "ibm_dns_custom_resolver" "test_hub_true" {
	# resource_group_id  	=  data.ibm_resource_group.rg.id
	name		   		=  "test-hub-true-customresolver"
	instance_id 	   	=  ibm_resource_instance.dns-cr-instance.guid
	description	   		=  "new test CR - TF"
	high_availability  	=  true
	enabled 	   		=  true
	locations {
			subnet_crn  = ibm_is_subnet.hub_true_sub1.crn
			enabled	 = true
	}
	locations {
			subnet_crn  = ibm_is_subnet.hub_true_sub2.crn
			enabled	 = true
	}
}
resource "ibm_dns_custom_resolver" "test_hub_false_delegated" {
	name		   		=  "test-hub-false-customresolver"
	# resource_group_id  	=  data.ibm_resource_group.rg.id
	instance_id 	   	=  ibm_resource_instance.dns-cr-instance.guid
	description	   		=  "new test CR - TF"
	high_availability  	=  true
	enabled 	   		=  true
	locations {
			subnet_crn  = ibm_is_subnet.hub_false_delegated_sub1.crn
			enabled	 = true
	}
	locations {
			subnet_crn  = ibm_is_subnet.hub_false_delegated_sub2.crn
			enabled	 = true
	}
}

resource ibm_is_vpc_dns_resolution_binding dnstrue {
	# resource_group  	=  data.ibm_resource_group.rg.id
	
	name = "hub-spoke-binding"
	vpc_id=  ibm_is_vpc.hub_false_delegated.id
	vpc {
		id = ibm_is_vpc.hub_true.id
	}
    force_delete = true
}

# resource "ibm_is_vpc" "testacc_vpc_manual" {
# 	name = "${var.name}-vpc-manual"
# 	dns {
# 		enable_hub = true
# 		# resolver {
# 		# 	# manual_servers {
# 		# 	# 	address = "192.168.3.4"
# 		# 	# }
# 		# 	# manual_servers {
# 		# 	# 	address = "192.168.1.4"
# 		# 	# }
# 		# 	type = "    system"
# 		# }
# 	}
# }
# resource "ibm_is_vpc" "testacc_vpc_manual_zone" {
# 	name = "${var.name}-vpc-manual-zone"
# 	dns {
# 		enable_hub = true
# 		resolver {
# 			manual_servers     {
# 				address ="192.168.0.4"
# 				zone_affinity= "${var.region}-1"
# 			}
# 			manual_servers{
# 				address= "192.168.128.4"
# 				zone_affinity ="${var.region}-3"
# 			}
# 			manual_servers{
# 				address =  "192.168.64.4"
# 				zone_affinity = "${var.region}-2"
# 			}
# 		}
# 	}
# }
# resource "ibm_is_vpc" "testacc_vpc_manual_zone2" {
# 	name = "${var.name}-vpc-manual-zone2"
# 	dns {
# 		enable_hub = true
# 		resolver {
# 			manual_servers     {
# 				address ="192.168.0.4"
# 				zone_affinity= "${var.region}-2"
# 			}
# 			# manual_servers{
# 			# 	address =  "192.168.64.4"
# 			# 	zone_affinity = "${var.region}-2"
# 			# }
# 			# manual_servers{
# 			# 	address= "192.168.128.4"
# 			# 	zone_affinity ="${var.region}-3"
# 			# }
# 		}
# 	}
# }
# resource "ibm_is_vpc" "testacc_vpc_manual_zone3" {
# 	name = "${var.name}-vpc-manual-zone3"
# 	dns {
# 		enable_hub = true
# 		resolver {
# 			# type = "system"
# 			manual_servers {
# 				address ="192.168.2.4"
# 				zone_affinity= "${var.region}-1"
# 			}
# 			manual_servers {
# 				address =  "192.168.64.4"
# 				zone_affinity = "${var.region}-2"
# 			}
# 			manual_servers {
# 				address= "192.168.128.4"
# 				zone_affinity ="${var.region}-3"
# 			}
# 		}
# 	}
# }
# resource ibm_is_vpc hub_false {
# 	name = "${var.name}-vpc-hub-truwe"
# 	dns {
# 		enable_hub = false
# 	}
# }

# resource "ibm_is_virtual_endpoint_gateway" "endpoint_gatewayfalse" {
# 	name = "${var.name}-egwfalsehubs"
# 	target {
# 		name          = "ibm-ntp-server"
# 		resource_type = "provider_infrastructure_service"
# 	}
# 	vpc = ibm_is_vpc.hub_false.id
# 	allow_dns_resolution_binding = false
# }
