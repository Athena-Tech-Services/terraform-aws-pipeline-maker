output "codepipeline_arn" {
  description = "codepipeline ARN"
  value       = aws_codepipeline.codepipeline.arn
}

output "codepipeline" {
  description = "codepipeline"
  value       = aws_codepipeline.codepipeline
}
