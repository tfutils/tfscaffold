resource "aws_cloudformation_stack" "transfer_server" {
  name = "${local.csi}-transfer-server"

  on_failure = "DELETE"

  template_body = yamlencode({
    Resources = {
      TransferServer = {
        Type = "AWS::Transfer::Server"

        Properties = {
          IdentityProviderType = "SERVICE_MANAGED"

          EndpointDetails = {
            AddressAllocationIds = var.sftp_endpoint_type == "VPC" ? aws_eip.main[*].id : null
            SecurityGroupIds     = var.sftp_endpoint_type != "PUBLIC" ? [ aws_security_group.main[0].id ] : []
            SubnetIds            = var.subnet_ids
            #VpcEndpointId        = var.sftp_endpoint_type == "VPC_ENDPOINT" ? var.vpc_id : null
            VpcId                = var.vpc_id
          }

          EndpointType = var.sftp_endpoint_type
          LoggingRole  = aws_iam_role.sftp_logs.arn

          Protocols = [
            "SFTP",
          ]

          SecurityPolicyName = "TransferSecurityPolicy-FIPS-2020-06"

          Tags = [ for k, v in merge(
            local.default_tags,
            {
              Name = "${local.csi}-transfer-server"
            }
          ) :
            { Key = k, Value = v }
          ]
        }
      }
    }

    Outputs = {
      id = {
        Value = {
          "Fn::GetAtt" = [
            "TransferServer",
            "ServerId",
          ]
        }
      }

      endpoint = {
        Value = {
          "Fn::Join" = [
            ".",
            [
              {
                "Fn::GetAtt" = [
                  "TransferServer",
                  "ServerId",
                ]
              },
              "server.transfer",
              {
                 Ref = "AWS::Region"
              },
              "amazonaws.com",
            ]
          ]
        }
      }
    }
  })

  tags = local.default_tags
}

